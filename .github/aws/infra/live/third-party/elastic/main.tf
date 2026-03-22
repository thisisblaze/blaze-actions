terraform {
  backend "s3" {}
  required_providers {
    ec = {
      source  = "elastic/ec"
      version = "~> 0.12.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "ec" {
  apikey = var.ec_api_key
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# ELASTIC CLOUD DEPLOYMENT MODULE
# ---------------------------------------------------------
module "elastic_deployment" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/third-party/elastic-deployment?ref=v2.1.2"

  # Required variables
  namespace   = var.namespace
  client_key  = var.client_key
  project_key = var.project_key
  stage       = var.stage

  # Elastic Cloud configuration
  ec_region       = var.ec_region_map[var.aws_region]
  elastic_version = "9.2.1"

  # Sizing
  elasticsearch_size       = var.elasticsearch_size
  elasticsearch_zone_count = var.elasticsearch_zone_count
  kibana_size              = var.kibana_size
  kibana_zone_count        = var.kibana_zone_count

  # Role configuration
  app_role_index_patterns = ["${var.namespace}-*", "logs-*", "metrics-*"]
  app_user_email          = var.tag_support

  # AWS SSM integration
  store_in_aws_ssm = true
  aws_ssm_prefix   = "/blaze/${var.client_key}/${var.platform}/${var.stage}/elastic"

  # Tags
  tags = {
    Client    = var.client_key
    Namespace = var.namespace
    Project   = var.project_key
    Stage     = var.stage
    ManagedBy = var.tag_managed_by
    Support   = var.tag_support
    State     = var.tag_state
  }
}

# TODO: Disaster Recovery Protection
# Lifecycle blocks cannot be applied to module declarations.
# To implement prevent_destroy:
# 1. Update blaze-terraform-infra-core/modules/third-party/elastic-deployment to support 'enable_prevent_destroy' variable
# 2. Apply lifecycle block inside the module on the actual ec_deployment resource
# 3. Then set: enable_prevent_destroy = var.stage == "prod" ? true : false


# ---------------------------------------------------------
# OUTPUTS (maintaining compatibility with existing output names)
# ---------------------------------------------------------
output "elastic_endpoint" {
  description = "Elasticsearch HTTPS endpoint"
  value       = module.elastic_deployment.elasticsearch_endpoint
  sensitive   = true
}

output "elastic_cloud_id" {
  description = "Elasticsearch Cloud ID"
  value       = module.elastic_deployment.elasticsearch_cloud_id
  sensitive   = true
}

output "elastic_username" {
  description = "Elasticsearch superuser username"
  value       = module.elastic_deployment.elasticsearch_username
}

output "elastic_password" {
  description = "Elasticsearch superuser password"
  value       = module.elastic_deployment.elasticsearch_password
  sensitive   = true
}

output "elastic_app_username" {
  description = "Application user username"
  value       = module.elastic_deployment.app_username
}

output "elastic_app_password" {
  description = "Application user password"
  value       = module.elastic_deployment.app_password
  sensitive   = true
}

output "kibana_endpoint" {
  description = "Kibana HTTPS endpoint"
  value       = module.elastic_deployment.kibana_endpoint
  sensitive   = true
}

output "deployment_id" {
  description = "Elastic Cloud deployment ID"
  value       = module.elastic_deployment.deployment_id
}
