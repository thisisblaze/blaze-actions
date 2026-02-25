# ─────────────────────────────────────────────────────────────
# DATA INFRASTRUCTURE (GCP STAGE)
# ─────────────────────────────────────────────────────────────
# Uses reusable modules from blaze-terraform-infra-core
# ─────────────────────────────────────────────────────────────

terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  default_labels = {
    client     = var.client_key
    namespace  = var.namespace
    project    = var.project_key
    stage      = var.stage
    managed-by = "terraform"
  }
}

# ── Remote State: Network ──
data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = "${var.namespace}-${var.client_key}-tfstate"
    prefix = "infra/${var.project_key}/${var.stage}/network"
  }
}

locals {
  vpc_id = try(data.terraform_remote_state.network.outputs.vpc_id, "")
}

# ── Memorystore Redis ──
module "redis" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/data/memorystore-redis?ref=v1.46.0"
  count  = var.enable_redis ? 1 : 0

  context        = {}
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  vpc_id         = local.vpc_id

  tier           = var.redis_tier
  memory_size_gb = var.redis_memory_size_gb
  redis_version  = var.redis_version

  # Create private service access (shared with Cloud SQL if both enabled)
  create_private_service_access = true
}

# ── Cloud SQL PostgreSQL ──
module "cloud_sql" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/data/cloud-sql?ref=v1.46.0"
  count  = var.enable_cloud_sql ? 1 : 0

  context        = {}
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  vpc_id         = local.vpc_id

  database_version    = var.cloud_sql_version
  tier                = var.cloud_sql_tier
  ha_enabled          = var.cloud_sql_ha
  disk_size           = var.cloud_sql_disk_size
  deletion_protection = var.cloud_sql_deletion_protection
  backup_enabled      = true # Always enable backups for stage

  database_name     = var.cloud_sql_database_name
  database_user     = var.cloud_sql_user
  database_password = var.cloud_sql_password

  # Don't create private service access if Redis already created it
  create_private_service_access = !var.enable_redis
}
