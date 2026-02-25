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
    # New naming: blaze-{client_key}-{platform}-{stage}-terraform-state
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/prod/network.tfstate"
    region = var.aws_region
  }
}


# --------------------------------------------------------------------------------
# LABEL MODULE (Required by EC2 Capacity Provider)
# --------------------------------------------------------------------------------
module "label" {
  source    = "github.com/thisisblaze/blaze-terraform-infra-core//modules/common/label?ref=v1.44.2"
  client    = var.client_key
  project   = var.project_key
  stage     = var.stage
  namespace = var.namespace
}

# --------------------------------------------------------------------------------
# ENVIRONMENT APP MODULE
# --------------------------------------------------------------------------------
module "app" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/environment-app?ref=v1.44.2"

  stage       = "prod"
  platform    = var.platform # New input for S3 naming
  client_key  = var.client_key
  project_key = var.project_key
  namespace   = var.namespace
  aws_region  = var.aws_region

  # Cluster & Network (From Remote State — unified .config pattern)
  cluster_id   = try(data.terraform_remote_state.network.outputs.config.cluster_id, data.terraform_remote_state.network.outputs.cluster_id, "")
  cluster_name = try(data.terraform_remote_state.network.outputs.config.cluster_name, data.terraform_remote_state.network.outputs.cluster_name, "")
  vpc_id       = try(data.terraform_remote_state.network.outputs.config.vpc_id, data.terraform_remote_state.network.outputs.vpc_id, "")
  # Use app_subnets (module handles no-NAT subnet routing)
  private_subnets  = try(data.terraform_remote_state.network.outputs.config.app_subnets, data.terraform_remote_state.network.outputs.app_subnets, data.terraform_remote_state.network.outputs.public_subnets, [])
  assign_public_ip = try(data.terraform_remote_state.network.outputs.config.public_ip_enabled, true) # Default true for no-NAT

  # Use CodeDeploy Blue/Green deploying for zero-downtime API rollouts
  api_force_rolling_deployment = false

  ecs_sg_id                      = try(data.terraform_remote_state.network.outputs.config.ecs_sg_id, data.terraform_remote_state.network.outputs.ecs_sg_id, "")
  service_discovery_namespace_id = try(data.terraform_remote_state.network.outputs.config.service_discovery_ns_id, data.terraform_remote_state.network.outputs.service_discovery_ns_id, "")
  execution_role_arn             = try(data.terraform_remote_state.network.outputs.config.execution_role_arn, data.terraform_remote_state.network.outputs.execution_role_arn, "")
  codedeploy_role_arn            = try(data.terraform_remote_state.network.outputs.config.codedeploy_role_arn, data.terraform_remote_state.network.outputs.codedeploy_role_arn, "")
  efs_id                         = try(data.terraform_remote_state.network.outputs.config.efs_id, data.terraform_remote_state.network.outputs.efs_id, "")
  api_ap_id                      = try(data.terraform_remote_state.network.outputs.config.api_ap_id, data.terraform_remote_state.network.outputs.api_ap_id, "")

  # Load Balancer & Listeners (From Remote State)
  alb_listener_arn     = try(data.terraform_remote_state.network.outputs.config.alb_listener_arn, data.terraform_remote_state.network.outputs.alb_listener_arn, "")
  alb_arn              = try(data.terraform_remote_state.network.outputs.config.alb_arn, data.terraform_remote_state.network.outputs.alb_arn, "")
  api_alb_listener_arn = "" # Empty to force usage of Default Action (Listener ARN)
  # Admin Listener ARN removed
  frontend_alb_listener_arn = try(data.terraform_remote_state.network.outputs.config.alb_listener_arn, data.terraform_remote_state.network.outputs.alb_listener_arn, "")


  # Target Groups (API)
  alb_target_group_blue_name  = try(data.terraform_remote_state.network.outputs.config.alb_tg_blue_name, data.terraform_remote_state.network.outputs.alb_tg_blue_name, "")
  alb_target_group_blue_arn   = try(data.terraform_remote_state.network.outputs.config.alb_tg_blue_arn, data.terraform_remote_state.network.outputs.alb_tg_blue_arn, "")
  alb_target_group_green_name = try(data.terraform_remote_state.network.outputs.config.alb_tg_green_name, data.terraform_remote_state.network.outputs.alb_tg_green_name, "")

  # Target Groups (Frontend)
  alb_target_group_frontend_blue_name  = try(data.terraform_remote_state.network.outputs.config.alb_tg_frontend_blue_name, data.terraform_remote_state.network.outputs.alb_tg_frontend_blue_name, "")
  alb_target_group_frontend_blue_arn   = try(data.terraform_remote_state.network.outputs.config.alb_tg_frontend_blue_arn, data.terraform_remote_state.network.outputs.alb_tg_frontend_blue_arn, "")
  alb_target_group_frontend_green_name = try(data.terraform_remote_state.network.outputs.config.alb_tg_frontend_green_name, data.terraform_remote_state.network.outputs.alb_tg_frontend_green_name, "")

  # Enable Backup Governance
  enable_backups = true

  # CloudFront / CDN
  # Reuse Network Stack's CDN (Upfront Pattern)
  domain_root             = var.domain_root
  enable_cloudfront       = false
  enable_frontend_cdn     = false # Delegated to Stage Network
  enable_assets_cdn       = false # Delegated to Stage Network (using external_cloudfront_arn)
  external_cloudfront_arn = try(data.terraform_remote_state.network.outputs.config.cloudfront_distribution_arn, data.terraform_remote_state.network.outputs.cdn_arn, "")

  cloudfront_acm_certificate_arn = try(data.terraform_remote_state.network.outputs.config.cloudfront_certificate_arn, var.cloudfront_acm_certificate_arn)

  # Launch Type — FARGATE (matching stage)
  # NOTE: EC2 launch type was planned for prod but the EC2 capacity provider association
  # fails with ResourceInUseException in prod-network. Switching to Fargate to unblock
  # deployments. Revisit EC2/Hybrid strategy once capacity provider is stabilized.
  api_launch_type            = "FARGATE"
  frontend_launch_type       = "FARGATE"
  ec2_capacity_provider_name = try(data.terraform_remote_state.network.outputs.ec2_capacity_provider_name, "")
}

# Removed EC2 Capacity Provider block and aws_ecs_cluster_capacity_providers; moved to prod-network stack
# CLOUDFLARE PAGES PROJECT (Admin)
# --------------------------------------------------------------------------------
module "pages_project_admin" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/pages-project?ref=v1.44.2"

  account_id = var.cloudflare_account_id

  # Standardized Naming: namespace-client-project-stage-admin
  project_name      = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-admin"
  production_branch = "main"
}



# --------------------------------------------------------------------------------
# MANUAL ALB LISTENER RULES (Prod)
# The environment-app module with enable_cloudfront=false does not create
# host-based routing rules for CF-fronted hostnames. Without these rules,
# the ALB default action (fixed-response 404) matches all CloudFront requests.
# --------------------------------------------------------------------------------

locals {
  alb_listener_arn = try(data.terraform_remote_state.network.outputs.config.alb_listener_arn, data.terraform_remote_state.network.outputs.alb_listener_arn, "")
}

data "aws_lb_target_group" "frontend_blue" {
  name = try(data.terraform_remote_state.network.outputs.config.alb_tg_frontend_blue_name, data.terraform_remote_state.network.outputs.alb_tg_frontend_blue_name, "${var.namespace}-${var.stage}-fe-blue-tg")
}

data "aws_lb_target_group" "api_blue" {
  name = try(data.terraform_remote_state.network.outputs.config.alb_tg_blue_name, data.terraform_remote_state.network.outputs.alb_tg_blue_name, "${var.namespace}-${var.stage}-api-blue-tg")
}

resource "aws_lb_listener_rule" "frontend_prod" {
  count        = local.alb_listener_arn != "" ? 1 : 0
  listener_arn = local.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.frontend_blue.arn
  }

  condition {
    host_header {
      values = ["frontend.${var.domain_root}"]
    }
  }
}

resource "aws_lb_listener_rule" "api_prod" {
  count        = local.alb_listener_arn != "" ? 1 : 0
  listener_arn = local.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api_blue.arn
  }

  condition {
    host_header {
      values = ["api.${var.domain_root}"]
    }
  }
}
