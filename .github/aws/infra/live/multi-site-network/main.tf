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
# NETWORK + CLUSTER
# ──────────────────────────────────────────────────────────────────────────────
module "environment_network" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/networking/environment-network?ref=v2.2.0"

  providers = { aws = aws }

  stage       = var.stage
  client_key  = var.client_key
  project_key = var.project_key
  namespace   = var.namespace
  aws_region  = var.aws_region

  # ── 3-AZ CIDR — 10.3.x.x (non-colliding: dev=10.0, stage=10.1, prod=10.2)
  vpc_cidr              = "10.3.0.0/16"
  private_subnets_cidrs = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  public_subnets_cidrs  = ["10.3.101.0/24", "10.3.102.0/24", "10.3.103.0/24"]

  # NAT Gateway: 1 in eu-west-1a for prod, none for dev/stage (cost saving)
  # Containers run in public subnets with assign_public_ip when no NAT
  nat_strategy = var.nat_strategy

  # TF state bucket follows the same pattern as other stacks
  tf_state_bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"

  # No Cloudflare tunnel — this stack exposes sites via ALB + CloudFront directly
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  domain_root          = var.domain_root

  # ALB enabled with HTTPS — required for 125 host-based routing rules
  enable_alb   = true
  alb_port     = 443
  alb_protocol = "HTTPS"

  # ACM cert covers *.{domain_root} — CloudFront handles per-site TLS,
  # ALB cert is only for the internal HTTPS listener health checks.
  acm_certificate_arn = var.acm_certificate_arn

  # No Cloudflare tunnel — multi-site uses ALB + CloudFront directly
  enable_tunnel = false

  # EFS not needed for stateless site containers
  enable_efs = false

  # Image resize not wired here (each site manages its own media if needed)
  enable_image_resize = false

  # Container Insights for observability across 120+ services
  container_insights_mode = var.stage == "prod" ? "enhanced" : "enabled"

  # Capacity providers: register Fargate + Fargate Spot on the cluster
  # The EC2 capacity provider is registered separately via ec2_capacity_provider module
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # Common tags
  tag_managed_by = var.tag_managed_by
  tag_support    = var.tag_support
  tag_state      = var.tag_state
}

# ──────────────────────────────────────────────────────────────────────────────
# EC2 ARM64 CAPACITY PROVIDER (Graviton ASG — standard tier sites)
# ──────────────────────────────────────────────────────────────────────────────
module "graviton_cp" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/ecs/ec2-capacity-provider?ref=v2.2.0"

  # Identity
  client_key  = var.client_key
  project_key = var.project_key
  namespace   = var.namespace
  env_handle  = var.stage
  context     = module.environment_network.context

  # Cluster
  cluster_name = module.environment_network.cluster_name

  # Networking — private subnets (with NAT for prod, public for dev/stage)
  vpc_id          = module.environment_network.vpc_id
  subnet_ids      = module.environment_network.app_subnets
  vpc_cidr_blocks = ["10.3.0.0/16"]

  # ARM64 Graviton instance types — mixed for Spot pool diversity
  cpu_architecture = "ARM64"
  instance_types   = ["c7g.large", "m7g.large", "t4g.large"]

  # Spot/On-Demand split:
  # - 2 on-demand base (stable floor, absorbs immediate demand)
  # - 70% Spot above base (cost optimized)
  on_demand_base_capacity         = var.stage == "prod" ? 2 : 0
  on_demand_percentage_above_base = var.stage == "prod" ? 30 : 0

  # ASG sizing
  asg_min_size         = var.ec2_asg_min
  asg_max_size         = var.ec2_asg_max
  asg_desired_capacity = var.ec2_asg_desired

  # Binpacking target: scale out when memory reservation hits 70%
  target_capacity_percent = 70
}

# ──────────────────────────────────────────────────────────────────────────────
# OUTPUTS — consumed by multi-site-app stack via remote state
# ──────────────────────────────────────────────────────────────────────────────
output "config" { value = module.environment_network.config }
output "cluster_id" { value = module.environment_network.cluster_id }
output "cluster_name" { value = module.environment_network.cluster_name }
output "vpc_id" { value = module.environment_network.vpc_id }
output "app_subnets" { value = module.environment_network.app_subnets }
output "public_ip_enabled" { value = module.environment_network.public_ip_enabled }
output "ecs_sg_id" { value = module.environment_network.ecs_sg_id }
output "service_discovery_ns_id" { value = module.environment_network.service_discovery_ns_id }
output "execution_role_arn" { value = module.environment_network.execution_role_arn }
output "codedeploy_role_arn" { value = module.environment_network.codedeploy_role_arn }
output "alb_listener_arn" { value = module.environment_network.alb_listener_arn }
output "alb_arn" { value = module.environment_network.alb_arn }
output "alb_dns_name" { value = module.environment_network.alb_dns_name }
output "ec2_capacity_provider_name" {
  description = "Name of the Graviton ARM64 EC2 Capacity Provider"
  value       = module.graviton_cp.capacity_provider_name
}
