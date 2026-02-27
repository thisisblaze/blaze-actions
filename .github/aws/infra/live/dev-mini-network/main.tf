terraform {
  backend "s3" {}
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# -------------------------------------------------------------------------
# NETWORK INFRASTRUCTURE (DEV)
# -------------------------------------------------------------------------
# Purpose:
#   - Standardized usage of environment-network module (Tunnel Mode)
#   - Creates VPC, subnets, ECS Cluster, EFS
#   - Defines Tunnel SG rules via variable
# -------------------------------------------------------------------------

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

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      Client       = var.client_key
      Namespace    = var.namespace
      Project      = var.project_key
      Stage        = var.stage
      "Managed by" = var.tag_managed_by
    }
  }
}

module "environment_network" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/networking/environment-network?ref=v1.49.0-fix1"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  stage       = var.stage
  client_key  = var.client_key
  project_key = var.project_key
  namespace   = var.namespace
  aws_region  = var.aws_region

  # Dev-Specific CIDR (Preserved)
  vpc_cidr              = "10.1.0.0/16"
  private_subnets_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets_cidrs  = ["10.1.101.0/24", "10.1.102.0/24"]

  # Cost Optimization: Use Public Subnets (No NAT Gateway)
  nat_strategy = "NONE"

  # Common Inputs
  tf_state_bucket = "${var.client_key}-${var.stage}-blaze-tfstate"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  domain_root          = var.domain_root

  # ⚠️ DEV MODE: Disable ALB (Uses Cloudflare Tunnel)
  enable_alb = false

  # ⚠️ DEV MODE: Enable EFS (Persistent Storage)
  enable_efs = false

  # ⚠️ DEV MODE: Custom Ingress Rules for Cloudflare Tunnel
  extra_ecs_sg_ingress_rules = [
    {
      description = "Allow Cloudflare Tunnel - API"
      from_port   = 3001
      to_port     = 3001
      protocol    = "tcp"
      self        = true
    },
    {
      description = "Allow Cloudflare Tunnel - Frontend"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      self        = true
    },
    {
      description = "Allow Cloudflare Tunnel - Admin"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      self        = true
    }
  ]

  enable_access_control = false

  # EC2 Capacity Providers (Hybrid ECS — Feb 2026)
  capacity_providers = var.enable_ec2 ? [{
    name   = module.ec2_capacity_provider[0].capacity_provider_name
    weight = 1
    base   = 0
  }] : []
}

# --------------------------------------------------------------------------------
# EC2 CAPACITY PROVIDER (Hybrid ECS — Feb 2026)
# --------------------------------------------------------------------------------
module "ec2_capacity_provider" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/ec2-capacity-provider?ref=v1.49.0-fix1"
  count  = var.enable_ec2 ? 1 : 0

  # Identity (context provides label defaults, but these are required)
  client_key  = var.client_key
  project_key = var.project_key
  namespace   = var.namespace
  env_handle  = var.stage
  context     = module.environment_network.context

  # Networking
  cluster_name    = module.environment_network.cluster_name
  vpc_id          = module.environment_network.vpc_id
  subnet_ids      = module.environment_network.app_subnets
  vpc_cidr_blocks = [var.vpc_cidr]

  # Instance config
  instance_types   = var.ec2_instance_types
  cpu_architecture = var.ec2_cpu_architecture

  # DEV: Spot only for cost savings
  on_demand_base_capacity         = 0
  on_demand_percentage_above_base = 0

  # ASG sizing
  asg_min_size         = var.ec2_min_size
  asg_max_size         = var.ec2_max_size
  asg_desired_capacity = var.ec2_desired_size
}

module "log_bucket" {
  source  = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/storage/s3?ref=v1.49.0-fix1"
  name    = "logs"
  context = module.environment_network.context
}

# Unified Output Removed (Duplicate)
# output "config" { value = module.environment_network.config }


# -------------------------------------------------------------------------
# STATE MIGRATION (Refactor 2025-12-19)
# -------------------------------------------------------------------------

# 1. Networking Module
moved {
  from = module.networking
  to   = module.environment_network.module.networking
}

# 2. ECS Cluster Module
moved {
  from = module.cluster
  to   = module.environment_network.module.cluster
}

# 3. Security Group (Module -> Resource)
# dev-network used module "security_group", inside it "aws_security_group.this"
# new module uses resource "aws_security_group.ecs_sg"
moved {
  from = module.security_group.aws_security_group.this
  to   = module.environment_network.aws_security_group.ecs_sg
}

# 4. EFS (Module -> Resource)
# dev-network used module "efs", inside it "aws_efs_file_system.main"
# new module uses resource "aws_efs_file_system.main"
moved {
  from = module.efs.aws_efs_file_system.main
  to   = module.environment_network.aws_efs_file_system.main
}

moved {
  from = module.efs.aws_efs_mount_target.targets
  to   = module.environment_network.aws_efs_mount_target.targets
}

# Access Points
moved {
  from = module.efs.aws_efs_access_point.aps["api"]
  to   = module.environment_network.aws_efs_access_point.api
}

moved {
  from = module.efs.aws_efs_access_point.aps["mongo"]
  to   = module.environment_network.aws_efs_access_point.mongo
}

moved {
  from = module.efs.aws_efs_access_point.aps["es"]
  to   = module.environment_network.aws_efs_access_point.es
}

# Note: Previous "moved" blocks from legacy manual resources can be removed or kept.
# Since we are moving FROM the state that resulted from those moves, we just need to target the CURRENT state.


# -------------------------------------------------------------------------
# RESOURCE MIGRATION (Cloudflare v5 — Feb 2026)
# -------------------------------------------------------------------------
# In Cloudflare provider v5, access policies are inline within
# the application resource. The standalone policy resources no
# longer exist, so we use 'removed' to drop them from state.

# Applications: moved into module (resource type unchanged in v5)
moved {
  from = cloudflare_zero_trust_access_application.frontend_dev
  to   = module.environment_network.cloudflare_zero_trust_access_application.frontend[0]
}

moved {
  from = cloudflare_zero_trust_access_application.admin_dev
  to   = module.environment_network.cloudflare_zero_trust_access_application.admin[0]
}

# Policies: removed from state (now inline in application resource)
removed {
  from = cloudflare_zero_trust_access_policy.frontend_dev_allow
  lifecycle { destroy = false }
}

removed {
  from = cloudflare_zero_trust_access_policy.admin_dev_allow
  lifecycle { destroy = false }
}
