terraform {
  backend "s3" {}
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
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

# ──────────────────────────────────────────────────────────────────────────────
# READ NETWORK LAYER OUTPUTS
# ──────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/multi-site/network.tfstate"
    region = var.aws_region
  }
}

locals {
  net = data.terraform_remote_state.network.outputs
}

# ──────────────────────────────────────────────────────────────────────────────
# MULTI-SITE APP
# ──────────────────────────────────────────────────────────────────────────────
module "multi_site_app" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/multi-site-app?ref=v1.47.0"

  # Identity
  namespace   = var.namespace
  client_key  = var.client_key
  project_key = var.project_key
  stage       = var.stage
  aws_region  = var.aws_region

  # ── SITES MAP ────────────────────────────────────────────────────────────────
  # Add / remove sites here. Changes show up as an exact ECS diff on terraform plan.
  # tier = "standard" → EC2 ARM64 ASG (Graviton), binpacked, $8-10/month
  # tier = "premium"  → Fargate ARM64 (Graviton Fargate), instant scale, CodeDeploy B/G
  sites = var.sites

  # ── SHARED CLUSTER / NETWORK ─────────────────────────────────────────────────
  cluster_id                     = local.net.cluster_id
  cluster_name                   = local.net.cluster_name
  vpc_id                         = local.net.vpc_id
  subnets                        = local.net.app_subnets
  ecs_sg_id                      = local.net.ecs_sg_id
  assign_public_ip               = local.net.public_ip_enabled # true when nat_strategy=NONE
  service_discovery_namespace_id = local.net.service_discovery_ns_id

  # ── IAM ──────────────────────────────────────────────────────────────────────
  execution_role_arn  = local.net.execution_role_arn
  codedeploy_role_arn = local.net.codedeploy_role_arn

  # ── ALB ──────────────────────────────────────────────────────────────────────
  alb_listener_arn = local.net.alb_listener_arn

  # Base priority for listener rules.
  # Rules are assigned: base + index(site_key), cycling through the sites map.
  # 100 = safe default (no other rules from this stack below 100).
  # If sharing ALB with the main app stack in future, bump to 200.
  listener_rule_priority_base = var.listener_rule_priority_base

  # ── EC2 CAPACITY PROVIDER (standard tier sites) ───────────────────────────
  ec2_capacity_provider_name = local.net.ec2_capacity_provider_name

  # ── OPTIONAL SHARED S3 ASSETS BUCKET ─────────────────────────────────────
  # If provided, each site's task role gets scoped read/write access to its prefix.
  assets_bucket_arn = var.assets_bucket_arn
}

# ──────────────────────────────────────────────────────────────────────────────
# OUTPUTS
# ──────────────────────────────────────────────────────────────────────────────
output "site_service_names" { value = module.multi_site_app.site_service_names }
output "site_target_group_arns" { value = module.multi_site_app.site_target_group_arns }
output "site_log_group_names" { value = module.multi_site_app.site_log_group_names }
output "site_task_role_arns" { value = module.multi_site_app.site_task_role_arns }
output "standard_site_count" { value = module.multi_site_app.standard_site_count }
output "premium_site_count" { value = module.multi_site_app.premium_site_count }
output "alb_dns_name" { value = local.net.alb_dns_name }
