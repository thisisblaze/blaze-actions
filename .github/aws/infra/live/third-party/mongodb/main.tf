terraform {
  backend "s3" {}
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.10"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

provider "aws" {
  region = var.aws_region
}

locals {
  # Only non-empty identity tags — keeps empty values out of provider tag APIs.
  identity_tags = merge(
    var.stack_id != "" ? { StackID = var.stack_id } : {},
    var.blaze_run_id != "" ? { RunId = var.blaze_run_id } : {},
  )
}

# ---------------------------------------------------------
# MONGODB ATLAS CLUSTER MODULE
# ---------------------------------------------------------
module "mongodb_cluster" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/mongodbatlas/cluster?ref=v2.11.14"

  # Required variables
  namespace   = var.namespace
  client_key  = var.client_key
  project_key = var.project_key
  stage       = var.stage

  # MongoDB Atlas configuration
  atlas_org_id     = var.atlas_org_id
  atlas_project_id = var.atlas_project_id
  atlas_region     = var.atlas_region_map[var.aws_region]
  cluster_tier     = var.cluster_tier
  is_paused        = var.is_paused

  # Network security
  trusted_ip_list = var.trusted_ip_list

  # AWS SSM integration
  store_in_aws_ssm = true
  aws_ssm_prefix   = "/blaze/${var.client_key}/${var.platform}/${var.stage}/mongodb"

  # Tags
  tags = merge({
    Client    = var.client_key
    Namespace = var.namespace
    Project   = var.project_key
    Stage     = var.stage
    ManagedBy = var.tag_managed_by
    Support   = var.tag_support
    State     = var.tag_state
  }, local.identity_tags)

  enable_prevent_destroy = var.stage == "prod"
}




# ---------------------------------------------------------
# OUTPUTS (maintaining compatibility with existing output names)
# ---------------------------------------------------------

output "mongodb_host" {
  description = "MongoDB host (without mongodb+srv://)"
  value       = split("/", replace(module.mongodb_cluster.connection_string, "mongodb+srv://", ""))[0]
  sensitive   = true
}

output "mongodb_database" {
  description = "MongoDB database name"
  value       = module.mongodb_cluster.database_name
}

output "atlas_cluster_name" {
  description = "Atlas cluster name"
  value       = module.mongodb_cluster.cluster_name
}

output "atlas_project_id" {
  description = "Atlas project ID"
  value       = module.mongodb_cluster.project_id
}

output "atlas_srv" {
  description = "MongoDB Atlas SRV connection string"
  value       = module.mongodb_cluster.connection_string
  sensitive   = true
}

output "atlas_srv_host" {
  description = "MongoDB Atlas SRV host"
  value       = split("/", replace(module.mongodb_cluster.connection_string, "mongodb+srv://", ""))[0]
  sensitive   = true
}

