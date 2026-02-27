terraform {
  backend "s3" {}
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
    random     = { source = "hashicorp/random", version = "~> 3.5" }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Client       = var.client_key
      Namespace    = var.namespace
      Project      = var.project_key
      Stage        = var.stage
      "Managed by" = "terraform"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  # Determine which base network to connect to (dev or stage)
  # If stage contains "dev", it's dev network. If "stage", it's stage network.
  # This supports feature branches on either environment.
  network_stage = strcontains(var.stage, "stage") ? "stage" : "dev-mini"

  # Dynamic App Stage (e.g. dev-ticket-123)
  app_stage = "dev-mini${var.branch_name != "" ? "-${var.branch_name}" : ""}"

  # Admin Hostname
  domain_root    = var.domain_root
  admin_hostname = "admin-${local.app_stage}.${local.domain_root}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${local.network_stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/${local.network_stage}/network.tfstate"
    region = var.aws_region
  }
}

# --------------------------------------------------------------------------------
# DEDICATED TUNNEL (FEATURE BRANCHES ONLY)
# --------------------------------------------------------------------------------
resource "random_id" "tunnel_secret" {
  count       = var.branch_name != "" ? 1 : 0
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "feature_branch" {
  count         = var.branch_name != "" ? 1 : 0
  account_id    = var.cloudflare_account_id
  name          = "${var.namespace}-${var.project_key}-${local.app_stage}-tunnel-${substr(random_id.tunnel_secret[0].hex, 0, 6)}"
  tunnel_secret = random_id.tunnel_secret[0].b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "feature_branch" {
  count      = var.branch_name != "" ? 1 : 0
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.feature_branch[0].id

  # Dynamically maps services based on naming convention
  # Hostname: api-{branch}-{stage}.domain (e.g. api-ticket-123-dev.thisisblaze.uk)
  # Service:  api-{branch}-{stage}.project-{net_stage}.local (e.g. api-dev-ticket-123.blaze-dev.local)
  config = {
    ingress = [
      {
        hostname = "api-${local.app_stage}.${var.domain_root}"
        service  = "http://api-${var.branch_name}.${var.project_key}-${local.network_stage}.local:3001"
        origin_request = {
          http_host_header = "api-${var.branch_name}.${var.project_key}-${local.network_stage}.local"
        }
      },
      {
        hostname = "frontend-${local.app_stage}.${var.domain_root}"
        service  = "http://frontend-${var.branch_name}.${var.project_key}-${local.network_stage}.local:3000"
        origin_request = {
          http_host_header = "frontend-${var.branch_name}.${var.project_key}-${local.network_stage}.local"
        }
      },
      {
        hostname = "admin-${local.app_stage}.${var.domain_root}"
        service  = "http://admin-${var.branch_name}.${var.project_key}-${local.network_stage}.local:80"
        origin_request = {
          http_host_header = "admin-${var.branch_name}.${var.project_key}-${local.network_stage}.local"
        }
      },
      {
        hostname = "kibana-${local.app_stage}.${var.domain_root}"
        service  = "http://kibana-${var.branch_name}.${var.project_key}-${local.network_stage}.local:5601"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "feature_branch_dns" {
  for_each = var.branch_name != "" ? toset(["api", "frontend", "admin", "kibana"]) : []
  zone_id  = var.cloudflare_zone_id

  # e.g. api-ticket-123-dev
  name    = "${each.key}-${local.app_stage}"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.feature_branch[0].id}.cfargotunnel.com"
  proxied = true
  ttl     = 1 # Auto
}

# --------------------------------------------------------------------------------
# APPLICATION MODULE
# --------------------------------------------------------------------------------
module "app" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/environment-app?ref=v1.49.0-fix4"

  context     = null # Will be generated inside if null, or pass label module output if we want strictly consistent labeling
  client_key  = var.client_key
  project_key = var.project_key
  stage       = local.app_stage
  namespace   = var.namespace
  aws_region  = var.aws_region
  platform    = var.platform

  enable_image_resize = false

  # Network Inputs
  cluster_id                     = try(data.terraform_remote_state.network.outputs.cluster_id, "")
  cluster_name                   = try(data.terraform_remote_state.network.outputs.cluster_name, "")
  vpc_id                         = try(data.terraform_remote_state.network.outputs.vpc_id, "")
  private_subnets                = try(data.terraform_remote_state.network.outputs.app_subnets, data.terraform_remote_state.network.outputs.private_subnets, [])
  assign_public_ip               = try(data.terraform_remote_state.network.outputs.public_ip_enabled, false)
  ecs_sg_id                      = try(data.terraform_remote_state.network.outputs.ecs_sg_id, "")
  service_discovery_namespace_id = try(data.terraform_remote_state.network.outputs.service_discovery_ns_id, "")
  execution_role_arn             = try(data.terraform_remote_state.network.outputs.execution_role_arn, "")
  codedeploy_role_arn            = "" # Dev often doesn't use CD, or uses same role

  # ALB (Optional in Dev if Tunnel is used, but typically present)
  alb_listener_arn           = try(data.terraform_remote_state.network.outputs.alb_listener_arn, "")
  alb_target_group_blue_name = "" # Dev Service creates its own TGs usually? No, `blaze-service` creates TGs if names are not provided?
  # WAIT. In the legacy `dev-app`, `blaze-service` was creating LBs because `create_lb_resources = true`.
  # The module `environment-app` sets `create_lb_resources = true` implicitly if `alb_listener_arn` is set?
  # Let's check `environment-app` logic... 
  # It passes `alb_listener_arn` to `blaze-service`. `blaze-service` creates TGs if they are not passed?
  # Yes, `blaze-service` main.tf: resource "aws_lb_target_group" "blue" { count = var.create_lb_resources && var.alb_target_group_blue_arn == "" ? 1 : 0 }
  # So we validly pass empty strings for existing TGs to let it create new ones.
  alb_target_group_blue_arn   = ""
  alb_target_group_green_name = ""

  # Frontend TGs (Dev creates its own)
  alb_target_group_frontend_blue_name  = ""
  alb_target_group_frontend_blue_arn   = ""
  alb_target_group_frontend_green_name = ""



  # EFS
  efs_id    = try(data.terraform_remote_state.network.outputs.efs_id, "")
  api_ap_id = try(data.terraform_remote_state.network.outputs.api_ap_id, "") # Might not exist in Dev Network yet

  # Domain (DEV does not use CloudFront)
  domain_root       = var.domain_root
  enable_cloudfront = false

  # Hybrid ECS — Feb 2026: Fargate is required for DEV because it lacks a NAT Gateway.
  # AWS prohibits assign_public_ip=true for EC2 tasks in awsvpc mode.
  api_launch_type            = "FARGATE"
  ec2_capacity_provider_name = try(data.terraform_remote_state.network.outputs.ec2_capacity_provider_name, "")

  # Config
  enable_backups = false
  enable_tunnel  = var.enable_tunnel
  tunnel_token   = local.tunnel_token

  # Stateful Services (Dev has them)
  deploy_stateful_services = var.deploy_stateful_services
  mongo_image_tag          = var.mongo_image_tag
  elasticsearch_image_tag  = var.elasticsearch_image_tag
  kibana_image_tag         = var.kibana_image_tag
  use_ecr_images           = var.use_ecr_images
}

# --------------------------------------------------------------------------------
# TUNNEL TOKEN LOOKUP (Legacy way)
# --------------------------------------------------------------------------------
data "terraform_remote_state" "cloudflare" {
  # HOST ONLY: Use shared tunnel state
  count   = var.enable_tunnel && var.branch_name == "" ? 1 : 0
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/third-party/cloudflare.tfstate"
    region = var.aws_region
  }
}

locals {
  # If branch, use new dedicated tunnel. If host, use shared tunnel.
  tunnel_token = var.branch_name != "" ? "" : try(data.terraform_remote_state.cloudflare[0].outputs.tunnel_token, "")
}

# --------------------------------------------------------------------------------
# MOVED BLOCKS (Critical for State Migration)
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

# Stateless Services
moved {
  from = module.api_container
  to   = module.app.module.api_container
}

moved {
  from = module.api
  to   = module.app.module.api_service
}

moved {
  from = module.frontend_container
  to   = module.app.module.frontend_container
}

moved {
  from = module.frontend
  to   = module.app.module.frontend_service
}

moved {
  from = module.admin_container
  to   = module.app.module.admin_container
}

moved {
  from = module.admin
  to   = module.app.module.admin_service
}

# Tunnel
moved {
  from = module.tunnel_container[0]
  to   = module.app.module.tunnel_container[0]
}

moved {
  from = module.tunnel_service[0]
  to   = module.app.module.tunnel_service[0]
}

# Stateful Services
moved {
  from = module.mongo_container
  to   = module.app.module.mongo_container[0] # Note: new module uses count
}

moved {
  from = module.mongo
  to   = module.app.module.mongo[0]
}

moved {
  from = module.elasticsearch_container
  to   = module.app.module.elasticsearch_container[0]
}

moved {
  from = module.elasticsearch
  to   = module.app.module.elasticsearch[0]
}

moved {
  from = module.kibana_container
  to   = module.app.module.kibana_container[0]
}

moved {
  from = module.kibana
  to   = module.app.module.kibana[0]
}

# Label (Root)
moved {
  from = module.label
  to   = module.app.module.label
}
# --------------------------------------------------------------------------------
# CLOUDFLARE PAGES (ADMIN HOST)
# --------------------------------------------------------------------------------
module "pages_project_admin" {
  # Create only for base DEV environment, not feature branches
  count = var.branch_name == "" ? 1 : 0

  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/pages-project?ref=v1.44.1"

  account_id = var.cloudflare_account_id

  # Naming: namespace-client-project-stage-admin (e.g. blaze-b9-thisisblaze-dev-admin)
  project_name      = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-admin"
  production_branch = "main"
}

# --------------------------------------------------------------------------------
# CLOUDFLARE PAGES CUSTOM DOMAIN
# --------------------------------------------------------------------------------
resource "cloudflare_pages_domain" "admin" {
  # Create only for base DEV environment
  count = var.branch_name == "" ? 1 : 0

  account_id   = var.cloudflare_account_id
  project_name = module.pages_project_admin[0].name
  name         = local.admin_hostname
}

# --------------------------------------------------------------------------------
# IMPORT BLOCKS (Fixes 409 Conflict for existing resources)
# --------------------------------------------------------------------------------
import {
  to = module.pages_project_admin[0].cloudflare_pages_project.this
  id = "${var.cloudflare_account_id}/${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-admin"
}

