# This file is shared between Dev and Prod
# It sets up the core networking foundation

terraform {
  backend "s3" {}
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Call our new lightweight module
module "networking" {
  source = "../modules/networking"

  env         = var.stage
  project_key = var.project_key
  vpc_cidr    = var.vpc_cidr
}

# 2. Setup the Cluster (It lives in the VPC)
resource "aws_ecs_cluster" "main" {
  name = "${var.namespace}-${var.project_key}-${var.stage}-cluster"

  setting {

    name  = "containerInsights"
    value = contains(["stage", "prod"], var.stage) ? "enhanced" : "disabled"
  }
}

# 3. Service Discovery Namespace (blaze.local)
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_key}-${var.stage}.local"
  description = "Service discovery for ${var.stage}"
  vpc         = module.networking.vpc_id
}

// infra/shared/main.tf - ADD THESE OUTPUT BLOCKS

output "vpc_id" {
  description = "The ID of the VPC created by the shared stack."
  value       = module.networking.vpc_id
}

output "private_subnets_ids" {
  description = "A list of private subnet IDs from the shared stack."
  value       = module.networking.private_subnets_ids
}

output "ecs_sg_id" {
  description = "The ID of the ECS Security Group created by the shared stack (needed for endpoint ingress)."
  # CRITICAL: Assuming an ECS Security Group exists in this shared directory or is outputted by another module called here.
  # If not defined here, this output needs to be adjusted. For now, we assume it's created nearby:
  value = aws_security_group.ecs_sg.id
}
