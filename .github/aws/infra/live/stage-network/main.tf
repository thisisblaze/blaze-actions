terraform {
  backend "s3" {}
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
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
      "Managed by" = var.tag_managed_by
      Support      = var.tag_support
      State        = var.tag_state
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# -------------------------------------------------------------------------
# NETWORK INFRASTRUCTURE (STAGE) - Refactored to use Module
# -------------------------------------------------------------------------
# Purpose:
#   - Standardized usage of environment-network module (matching Prod)
#   - Creates VPC, subnets, ECS Cluster, ALB/EFS/DNS resources
# -------------------------------------------------------------------------

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
      Support      = var.tag_support
      State        = var.tag_state
    }
  }
}

module "environment_network" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/networking/environment-network?ref=v1.44.1"

  # Override Frontend Subdomain to be 'frontend-stage'
  frontend_subdomain_override = "frontend-stage"
  # extra_cloudfront_aliases removed as we only want one domain

  # New Feature: Separate CDN Distribution (For WAF Isolation)
  separate_cdn_distribution = true # Matching Prod for parity
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  listener_default_action_target = "fixed-response"
  stage                          = "stage" # Explicitly stage
  client_key                     = var.client_key
  project_key                    = var.project_key

  # Disable Cloudflare Access for Stage (Granular)
  enable_frontend_access = false
  enable_admin_access    = false
  namespace              = var.namespace
  aws_region             = var.aws_region

  # Stage-Specific CIDR (Preserved from original)
  vpc_cidr              = "10.1.0.0/16"
  private_subnets_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets_cidrs  = ["10.1.101.0/24", "10.1.102.0/24"]
  # Stage: Use NAT Gateway (Standard) - Fixed connectivity issue
  nat_strategy            = "GATEWAY"
  container_insights_mode = "enabled"

  # Health Check: Use favicon.ico (static, no SSR) to avoid Next.js fetch hang on ALB probe
  # GET / triggers SSR which calls loadEntities() fetch → API returns HTML → JSON.parse hangs → 5s ALB timeout
  health_check_path    = "/favicon.ico"
  health_check_matcher = "200-499"

  # Wrapper Logic: Pass bucket for internal ACM lookup
  tf_state_bucket = "${var.client_key}-${var.stage}-blaze-tfstate"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  domain_root          = var.domain_root

  # Enable Beta URLs for initial testing (optional, usually false for stage)
  is_beta = var.is_beta

  # ⚠️ Disabling EFS Globally as per request
  enable_efs = false

  # Original Prod had `create_ecr_repos = true`. Stage usually reads or creates if separate.
  create_ecr_repos = false

  # Enable Security Features (WAF — matching Prod)
  enable_waf = true

  # EC2 Capacity Providers (Hybrid ECS — Feb 2026)
  capacity_providers = var.enable_ec2 ? [{
    name   = module.ec2_capacity_provider[0].capacity_provider_name
    weight = 1
    base   = 0
  }] : []

  # --- CLOUDFRONT ENABLEMENT ---
  enable_cloudfront             = true
  create_cloudfront_certificate = true
  # Also create ALB certificate
  create_acm_certificate = true
  # Route53 Zone ID required for automated cert validation
  route53_parent_zone_id = var.route53_parent_zone_id

  # Explicitly use AllViewer Policy to forward Host header to ALB
  # This fixes the issue where ALB receives the backend DNS name instead of the Host
  cloudfront_origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"


  # --- IMAGE RESIZE (Matching Prod) ---
  enable_image_resize    = true
  sharp_layer_arn        = var.sharp_layer_arn
  basic_auth_credentials = var.basic_auth_credentials

  # Storage Bucket Origin: intentionally omitted during network stack provisioning.
  # The storage S3 bucket is created by the app stack (stage-app). Adding this origin
  # before the bucket exists causes CloudFront NoSuchOrigin errors.
  # Re-run 01-provision-infra (stack=network) after stage-app is provisioned to wire it in.
  # storage_bucket_domain_name = "${var.namespace}-${var.client_key}-${var.platform}-${var.project_key}-${var.stage}-storage-origin.s3.${var.aws_region}.amazonaws.com"
  # storage_bucket_origin_id   = "storage-origin"

  # Custom Behaviors (API goes to ALB, everything else Default)
  # This relies on the default behavior pointing to ALB as well.
  # If we need specific paths (e.g. /api/*) to have different caching:
  cloudfront_ordered_cache_behaviors = [
    # GraphQL API (Proxied to ALB) - NO AUTH
    {
      path_pattern             = "graphql"
      target_origin_id         = "ALB-${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-ecs"
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD", "OPTIONS"]
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
      compress                 = true
      function_association     = [] # Explicitly Disable Basic Auth
    },
    # Health Check - NO AUTH
    {
      path_pattern             = "/health"
      target_origin_id         = "ALB-${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-ecs"
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
      compress                 = true
      function_association     = [] # Explicitly Disable Basic Auth
    },
    # Static Assets (JS) -> Frontend
    {
      path_pattern           = "*.js"
      target_origin_id       = "ALB-${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-ecs"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
      compress               = true
    },
    # Static Assets (CSS) -> Frontend
    {
      path_pattern           = "*.css"
      target_origin_id       = "ALB-${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-ecs"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
      compress               = true
    },
    # API Path Pattern (Legacy/Redundant but safe to keep) - NO AUTH
    {
      path_pattern             = "/api/*"
      target_origin_id         = "ALB-${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-ecs"
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      compress                 = true
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      function_association     = [] # Explicitly Disable Basic Auth
    },
    # Next.js Static Assets (/_next/*) - NO BASIC AUTH
    {
      path_pattern             = "/_next/*"
      target_origin_id         = "ALB-${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-ecs"
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
      origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-AllViewer
      compress                 = true
    }
  ]
}

# Unified Output
# Unified Config Output (New Standard)
output "config" { value = module.environment_network.config }

# Flattened Outputs (Legacy Compatibility for stage-app)
output "cluster_id" { value = module.environment_network.config.cluster_id }
output "cluster_name" { value = module.environment_network.config.cluster_name }
output "vpc_id" { value = module.environment_network.config.vpc_id }
output "private_subnets" { value = module.environment_network.config.private_subnets }
output "ecs_sg_id" { value = module.environment_network.config.ecs_sg_id }
output "service_discovery_ns_id" { value = module.environment_network.config.service_discovery_ns_id }
output "execution_role_arn" { value = module.environment_network.config.execution_role_arn }
output "codedeploy_role_arn" { value = module.environment_network.config.codedeploy_role_arn }
output "efs_id" { value = module.environment_network.config.efs_id }
output "api_ap_id" { value = module.environment_network.config.api_ap_id }
output "alb_listener_arn" { value = module.environment_network.config.alb_listener_arn }

# --------------------------------------------------------------------------------
# EC2 CAPACITY PROVIDER (Hybrid ECS — Feb 2026)
# --------------------------------------------------------------------------------

# Import orphaned IAM role — exists in AWS but was lost from state during a
# previous nuke/re-provision cycle. This block reconciles it so Terraform can
# manage it without hitting EntityAlreadyExists on the next apply.
# Safe to leave in place; Terraform ignores import blocks after first apply.


module "ec2_capacity_provider" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/ec2-capacity-provider?ref=v1.44.1"
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
  vpc_cidr_blocks = [try(module.environment_network.config.vpc_cidr_block, "10.1.0.0/16")]

  # Instance config
  instance_types   = var.ec2_instance_types
  cpu_architecture = var.ec2_cpu_architecture

  # STAGE: Spot only for cost savings (Demo Mode)
  on_demand_base_capacity         = 0
  on_demand_percentage_above_base = 0

  # ASG sizing
  asg_min_size         = var.ec2_min_size
  asg_max_size         = var.ec2_max_size
  asg_desired_capacity = var.ec2_desired_size
}

module "log_bucket" {
  source  = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/storage/s3?ref=v1.44.1"
  name    = "logs"
  context = module.environment_network.context
}

output "ec2_capacity_provider_name" {
  description = "Name of the EC2 Capacity Provider"
  value       = var.enable_ec2 ? module.ec2_capacity_provider[0].capacity_provider_name : ""
}
