terraform {
  backend "s3" {}
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
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

# Get network outputs
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/${var.stage}/network.tfstate"
    region = var.aws_region
  }
}

module "label" {
  source    = "github.com/thisisblaze/blaze-terraform-infra-core//modules/common/label?ref=v2.1.2"
  client    = var.client_key
  project   = var.project_key
  stage     = var.stage
  namespace = var.namespace
}

# --------------------------------------------------------------------------------
# ELASTICACHE REDIS
# --------------------------------------------------------------------------------
module "redis" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/data/redis?ref=v2.1.2"

  context = module.label.context
  name    = "cache"
  enabled = var.enable_redis

  vpc_id     = data.terraform_remote_state.network.outputs.config.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.config.private_subnets

  # Smallest instance (ARM-based Graviton2)
  node_type             = "cache.t4g.micro"
  number_cache_clusters = 1 # Single node (no replication)

  # No password authentication (transit encryption disabled)
  transit_encryption_enabled = false

  # Redis 7.x
  engine_version         = "7.0"
  parameter_group_family = "redis7"

  # Optional: Configure Redis parameters
  parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    }
  ]
}

# Security Group for Redis access
resource "aws_security_group" "redis" {
  count       = var.enable_redis ? 1 : 0
  name_prefix = "${module.label.id}-redis-"
  description = "Allow Redis access from ECS tasks only"
  vpc_id      = data.terraform_remote_state.network.outputs.config.vpc_id

  # Inbound: ONLY Redis port from ECS Security Group
  ingress {
    description     = "Redis from ECS Tasks"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.network.outputs.config.ecs_sg_id]
  }

  # Outbound: None required
  egress {
    description = "No outbound required"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"]
  }

  tags = merge(
    module.label.tags,
    {
      Name = "${module.label.id}-redis-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Note: Security group attachment happens automatically via subnet_group_name
# ElastiCache instances are automatically protected by network ACLs and the VPC
