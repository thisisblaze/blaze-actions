terraform {
  backend "s3" {}
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Client       = var.client_key
      Namespace    = var.namespace
      Project      = var.project_key
      Stage        = var.stage
      "Managed by" = var.tag_managed_by
      Support      = var.tag_support
      State        = var.tag_state
    }
  }
}

# RETRIEVE NETWORK LAYER
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/${var.stage}/network.tfstate"
    region = var.aws_region
  }
}

# data "aws_lb" "fallback" REMOVED - using regex on listener ARN instead to avoid guessing naming conventions.


locals {
  net_outputs = data.terraform_remote_state.network.outputs
  net_config  = try(local.net_outputs.config, {})

  cluster_id      = try(local.net_outputs.cluster_id, local.net_config.cluster_id, "")
  cluster_name    = try(local.net_outputs.cluster_name, local.net_config.cluster_name, "")
  vpc_id          = try(local.net_outputs.vpc_id, local.net_config.vpc_id, "")
  private_subnets = try(local.net_outputs.app_subnets, local.net_config.app_subnets, local.net_outputs.private_subnets, local.net_config.private_subnets, [])

  assign_public_ip               = try(local.net_outputs.public_ip_enabled, local.net_config.public_ip_enabled, true) # Default to true for Stage (No NAT)
  ecs_sg_id                      = try(local.net_outputs.ecs_sg_id, local.net_config.ecs_sg_id, "")
  service_discovery_namespace_id = try(local.net_outputs.service_discovery_ns_id, local.net_config.service_discovery_ns_id, "")
  execution_role_arn             = try(local.net_outputs.execution_role_arn, local.net_config.execution_role_arn, "")
  codedeploy_role_arn            = try(local.net_outputs.codedeploy_role_arn, local.net_config.codedeploy_role_arn, "")

  alb_listener_arn = try(local.net_outputs.alb_listener_arn, local.net_config.alb_listener_arn, "")

  # EC2 Capacity Provider
  ec2_capacity_provider_name = try(local.net_outputs.ec2_capacity_provider_name, "")

  # ROBUST ALB NAME EXTRACTION:
  # ARN Format: arn:aws:elasticloadbalancing:region:account:listener/app/load-balancer-name/lb-id/listener-id
  # Regex to capture 'load-balancer-name'
  alb_name_from_arn = local.alb_listener_arn != "" ? regex("app/([^/]+)/", local.alb_listener_arn)[0] : ""

  # Use extracted name, or fallback to dns name logic if needed (but without the data source)
  alb_dns_name = coalesce(try(local.net_outputs.alb_dns_name, ""), try(local.net_config.alb_dns_name, ""), "${var.stage}-alb-placeholder.com")


  # CloudFront Cert
  cloudfront_certificate_arn = try(local.net_outputs.cloudfront_certificate_arn, local.net_config.cloudfront_certificate_arn, "") # Pass through or empty

  # Hostnames
  domain_root    = var.domain_root
  is_prod        = var.stage == "prod"
  admin_hostname = local.is_prod ? "admin.${local.domain_root}" : "admin-${var.stage}.${local.domain_root}"
}

# --------------------------------------------------------------------------------
# 3. ADMIN INGRESS (Kept Local as it owns TGs unique to this stack)
# --------------------------------------------------------------------------------


module "label" {
  source    = "github.com/thisisblaze/blaze-terraform-infra-core//modules/common/label?ref=v2.1.2"
  client    = var.client_key
  project   = var.project_key
  stage     = var.stage
  namespace = var.namespace
}

# --------------------------------------------------------------------------------
# APPLICATION MODULE
# --------------------------------------------------------------------------------
module "app" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/environment-app?ref=v2.1.2"

  context     = module.label.context
  client_key  = var.client_key
  project_key = var.project_key
  stage       = var.stage
  namespace   = var.namespace
  aws_region  = var.aws_region
  platform    = var.platform

  # Launch Type (Stage uses FARGATE, Prod uses EC2)
  api_launch_type            = "FARGATE"
  api_cpu_architecture       = "X86_64"
  frontend_launch_type       = "FARGATE"
  frontend_cpu_architecture  = "X86_64"
  ec2_capacity_provider_name = local.ec2_capacity_provider_name

  # Network Inputs
  cluster_id                     = local.cluster_id
  cluster_name                   = local.cluster_name
  vpc_id                         = local.vpc_id
  private_subnets                = local.private_subnets
  assign_public_ip               = local.assign_public_ip
  ecs_sg_id                      = local.ecs_sg_id
  service_discovery_namespace_id = local.service_discovery_namespace_id
  execution_role_arn             = local.execution_role_arn
  codedeploy_role_arn            = local.codedeploy_role_arn

  # ALB Listeners (Specific Rules for CodeDeploy)
  alb_listener_arn = local.alb_listener_arn
  alb_name         = local.alb_name_from_arn # Explicitly pass the correct ALB name found in Network stack
  # Use the main listener for both API and Frontend rules
  api_alb_listener_arn         = local.alb_listener_arn
  api_force_rolling_deployment = false # Use CodeDeploy B/G since we have isolated host-based rules
  frontend_alb_listener_arn    = local.alb_listener_arn

  # Existing TGs (Looked up in main.tf previously)
  # Previous main.tf used `data "aws_lb_target_group" "api_blue"`.
  # We need to preserve that lookup if we want to bind to Network-created TGs.
  # So we probably need those data blocks here too!

  alb_target_group_blue_name  = try(data.aws_lb_target_group.api_blue[0].name, "")
  alb_target_group_blue_arn   = try(data.aws_lb_target_group.api_blue[0].arn, "")
  alb_target_group_green_name = try(data.aws_lb_target_group.api_green[0].name, "")

  alb_target_group_frontend_blue_name  = try(data.aws_lb_target_group.fe_blue[0].name, "")
  alb_target_group_frontend_blue_arn   = try(data.aws_lb_target_group.fe_blue[0].arn, "")
  alb_target_group_frontend_green_name = try(data.aws_lb_target_group.fe_green[0].name, "")

  # EFS
  efs_id    = try(local.net_outputs.efs_id, local.net_config.efs_id, "")
  api_ap_id = try(local.net_outputs.api_ap_id, local.net_config.api_ap_id, "")

  # CloudFront Configuration - DISABLED (network stack manages image resize CDN)
  domain_root         = var.domain_root
  enable_cloudfront   = false # Network stack manages CloudFront with image resize
  enable_frontend_cdn = false # Delegated to stage-network (CloudFront Upfront)
  enable_assets_cdn   = false # DISABLED - Network stack manages cdn-stage with image resize

  cloudfront_acm_certificate_arn = local.cloudfront_certificate_arn != "" ? local.cloudfront_certificate_arn : var.cloudfront_acm_certificate_arn

  # Config
  enable_backups        = true
  backup_retention_days = var.backup_retention_days

  # Stateful / Tunnel
  deploy_stateful_services = var.deploy_stateful_services
  enable_tunnel            = false

  mongo_image_tag         = var.mongo_image_tag
  elasticsearch_image_tag = var.elasticsearch_image_tag
  kibana_image_tag        = var.kibana_image_tag
  use_ecr_images          = var.use_ecr_images

  # OAC Logic
  external_cloudfront_arn = try(local.net_config.cloudfront_distribution_arn, "")
}

# --------------------------------------------------------------------------------
# TG LOOKUPS (Preserved from old main.tf)
# --------------------------------------------------------------------------------
data "aws_lb_target_group" "api_blue" {
  count = local.cluster_id == "" ? 0 : 1
  name  = "${var.namespace}-${var.stage}-api-blue-tg"
}

data "aws_lb_target_group" "api_green" {
  count = local.cluster_id == "" ? 0 : 1
  name  = "${var.namespace}-${var.stage}-api-green-tg"
}

data "aws_lb_target_group" "fe_blue" {
  count = local.cluster_id == "" ? 0 : 1
  name  = "${var.namespace}-${var.stage}-fe-blue-tg"
}

data "aws_lb_target_group" "fe_green" {
  count = local.cluster_id == "" ? 0 : 1
  name  = "${var.namespace}-${var.stage}-fe-green-tg"
}


# --------------------------------------------------------------------------------
# CLOUDFLARE PAGES PROJECT (Admin)
# --------------------------------------------------------------------------------
module "pages_project_admin" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/pages-project?ref=v2.1.2"

  account_id        = var.cloudflare_account_id
  project_name      = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-admin"
  production_branch = "main"
}

# --------------------------------------------------------------------------------
# CLOUDFLARE PAGES CUSTOM DOMAIN
# --------------------------------------------------------------------------------
resource "cloudflare_pages_domain" "admin" {
  account_id   = var.cloudflare_account_id
  project_name = module.pages_project_admin.name
  name         = local.admin_hostname
}


# --------------------------------------------------------------------------------
# MOVED BLOCKS
# --------------------------------------------------------------------------------

# Storage & IAM
moved {
  from = module.storage
  to   = module.app.module.storage
}

moved {
  from = module.image_resize
  to   = module.app.module.image_resize
}

moved {
  from = aws_iam_role.api_task_role
  to   = module.app.aws_iam_role.api_task_role
}

moved {
  from = aws_iam_role_policy.api_s3_access
  to   = module.app.aws_iam_role_policy.api_s3_access
}

# Services
moved {
  from = module.api_container
  to   = module.app.module.api_container
}

moved {
  from = module.api_refactored
  to   = module.app.module.api_service
}

moved {
  from = module.frontend_container
  to   = module.app.module.frontend_container
}

moved {
  from = module.frontend_refactored
  to   = module.app.module.frontend_service
}



# Backup
moved {
  from = module.backup
  to   = module.app.module.backup
}

# CDN
moved {
  from = module.cdn
  to   = module.app.module.cdn
}

moved {
  from = module.frontend_cdn
  to   = module.app.module.frontend_cdn
}

# Cache Policies
moved {
  from = aws_cloudfront_cache_policy.frontend_graphql
  to   = module.app.aws_cloudfront_cache_policy.frontend_graphql
}

moved {
  from = aws_cloudfront_cache_policy.frontend_static
  to   = module.app.aws_cloudfront_cache_policy.frontend_static
}

moved {
  from = aws_cloudfront_cache_policy.frontend_default
  to   = module.app.aws_cloudfront_cache_policy.frontend_default
}

# --------------------------------------------------------------------------------
# CLOUDFLARE PAGES PROJECT (Admin)
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
# CDN DNS RECORD (Points to Assets CloudFront Distribution)
# --------------------------------------------------------------------------------
resource "cloudflare_dns_record" "cdn" {
  count   = module.app.assets_cdn_enabled ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = local.is_prod ? "cdn" : "cdn-${var.stage}"
  type    = "CNAME"
  content = module.app.cloudfront_domain_name
  proxied = false # CloudFront DNS - don't proxy through Cloudflare
  ttl     = 1     # Auto
}



# --------------------------------------------------------------------------------
# WORKAROUND: Manual ALB Listener Rules
# The environment-app module fails to create rules when enable_cloudfront=false
# and no tunnel is used. We create them explicitly here.
# --------------------------------------------------------------------------------

# Retrieve ALB info to get DNS Name (CloudFront might send this as Host header)
data "aws_lb_listener" "selected_stage" {
  count = local.alb_listener_arn != "" ? 1 : 0
  arn   = local.alb_listener_arn
}

data "aws_lb" "selected_stage" {
  count = local.alb_listener_arn != "" ? 1 : 0
  arn   = data.aws_lb_listener.selected_stage[0].load_balancer_arn
}

resource "aws_lb_listener_rule" "api_manual" {
  count = local.alb_listener_arn != "" ? 1 : 0

  listener_arn = local.alb_listener_arn
  # priority     = 100 # Let AWS assign priority to avoid conflicts

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api_blue[0].arn
  }

  condition {
    host_header {
      values = ["api-${var.stage}.${var.domain_root}"]
    }
  }
}

resource "aws_lb_listener_rule" "frontend_manual" {
  # Create rule for Frontend hostname (without "api-")
  count = local.alb_listener_arn != "" ? 1 : 0

  listener_arn = local.alb_listener_arn
  # priority     = 110 # Let AWS assign priority to avoid conflicts

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.fe_blue[0].arn
  }

  condition {
    host_header {
      values = [
        "frontend-${var.stage}.${var.domain_root}"
      ]
    }
  }
}


