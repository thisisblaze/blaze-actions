terraform {
  backend "s3" {}
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
  }
}
# -------------------------------------------------------------------------
# NETWORK INFRASTRUCTURE (STAGE/PROD ONLY)
# -------------------------------------------------------------------------
# ⚠️  IMPORTANT: This stack is for STAGE and PROD environments ONLY.
#     DEV environments use Cloudflare Tunnel instead (no VPC/ALB needed).
#     See: .github/aws/infra/live/third-party/cloudflare/ for DEV setup.
#
# Purpose:
#   - Creates VPC, subnets, and network security groups
#   - Provisions ECS Fargate cluster
#   - Sets up Application Load Balancer (ALB) with HTTPS listener
#   - Configures DNS records pointing to ALB (not Cloudflare Tunnel)
#   - Creates EFS storage for stateful services
#
# Usage:
#   - Deploy this stack for STAGE or PROD environments
#   - Do NOT deploy for DEV (uses Cloudflare Tunnel, no ALB)
#   - Requires ACM certificates to be deployed first (see third-party/acm)
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
      Support      = var.tag_support
      State        = var.tag_state
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "environment_network" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/networking/environment-network?ref=v2.2.0"

  # New Feature: Separate CDN Distribution (For WAF Isolation)
  # Must remain true — cloudfront_cdn[0] path exists in Terraform state from prior applies.
  # Changing to false causes destroy+create CNAME conflict.
  separate_cdn_distribution = true
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  stage                   = "prod"
  client_key              = var.client_key
  project_key             = var.project_key
  namespace               = var.namespace
  vpc_cidr                = "10.2.0.0/16"
  private_subnets_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
  public_subnets_cidrs    = ["10.2.101.0/24", "10.2.102.0/24"]
  nat_strategy            = "GATEWAY"
  aws_region              = var.aws_region
  container_insights_mode = "enabled"

  # Wrapper Logic: Pass bucket for internal ACM lookup
  tf_state_bucket = "${var.client_key}-${var.stage}-blaze-tfstate"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  domain_root          = var.domain_root

  # Enable Beta URLs for initial testing
  is_beta = var.is_beta

  # ⚠️ Disabling EFS Globally as per request
  enable_efs = false

  # ECR repositories are shared across environments (created once, referenced by all)
  create_ecr_repos = false

  # Disable Cloudflare Access for Prod (Using Basic Auth Workers instead)
  enable_frontend_access = false
  enable_admin_access    = false
  enable_admin_alb       = false # Explicitly disable Admin ALB Rule/TG

  # Disable WAF (matching stage configuration)
  enable_waf = true

  # Set Listener Default Action Target (Fixed Response for safe default)
  listener_default_action_target = "fixed-response"

  # --- CLOUDFRONT ENABLEMENT ---
  # CF fully enabled — ACM cert validated, ALB origin -ecs suffix matches module internals.
  enable_cloudfront             = true
  create_cloudfront_certificate = true
  create_acm_certificate        = true
  route53_parent_zone_id        = var.route53_parent_zone_id

  # Add frontend hostname as CF alias so the distribution responds to frontend.thisisblaze.uk.
  # CloudFront silently drops connections for SNI hostnames not listed as distribution aliases.
  extra_cloudfront_aliases = ["frontend.thisisblaze.uk"]

  basic_auth_credentials = var.basic_auth_credentials

  # Forward original Host header to ALB (required for ALB listener rule matching).
  # Without this, CloudFront sends the ALB DNS name as Host, breaking all host-based routing.
  cloudfront_origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer

  # --- IMAGE RESIZE ---
  enable_image_resize = true                # ENABLED - Lambda@Edge image resizing
  sharp_layer_arn     = var.sharp_layer_arn # Sharp Layer ARN from CI/CD workflow

  # Custom Behaviors (API goes to ALB, everything else Default)
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
output "config" { value = module.environment_network.config }

# --------------------------------------------------------------------------------
# EC2 CAPACITY PROVIDER (Hybrid ECS - Prod)
# --------------------------------------------------------------------------------
module "ec2_capacity_provider" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/ec2-capacity-provider?ref=v2.2.0"

  # Identity
  client_key  = var.client_key
  project_key = var.project_key
  namespace   = var.namespace
  env_handle  = var.stage
  context     = module.environment_network.context

  # Networking
  cluster_name    = module.environment_network.cluster_name
  vpc_id          = module.environment_network.vpc_id
  subnet_ids      = module.environment_network.public_subnets # EC2 in Public (Prod has no NAT)
  vpc_cidr_blocks = [try(module.environment_network.config.vpc_cidr_block, "10.2.0.0/16")]

  # Instance config (Prod Optimized)
  instance_types   = var.ec2_instance_types
  cpu_architecture = var.ec2_cpu_architecture

  # PROD: 50% On-Demand / 50% Spot for Balance
  on_demand_base_capacity         = 1  # Ensure at least 1 OD instance
  on_demand_percentage_above_base = 50 # 50% split for scaling

  # ASG sizing
  asg_min_size         = var.ec2_min_size
  asg_max_size         = var.ec2_max_size
  asg_desired_capacity = var.ec2_desired_size
}

# --------------------------------------------------------------------------------
# CLUSTER ↔ CAPACITY PROVIDER ASSOCIATION
# --------------------------------------------------------------------------------
resource "aws_ecs_cluster_capacity_providers" "prod" {
  cluster_name = module.environment_network.cluster_name

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
    module.ec2_capacity_provider.capacity_provider_name,
  ]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }
}

# --------------------------------------------------------------------------------
# LOGGING BUCKET (Matches Stage)
# --------------------------------------------------------------------------------
module "log_bucket" {
  source  = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/storage/s3?ref=v2.2.0"
  name    = "logs"
  context = module.environment_network.context
}

output "ec2_capacity_provider_name" {
  description = "Name of the EC2 Capacity Provider"
  value       = module.ec2_capacity_provider.capacity_provider_name
}

