# ─────────────────────────────────────────────────────────────
# APPLICATION INFRASTRUCTURE (GCP DEV)
# ─────────────────────────────────────────────────────────────
# Uses reusable module from blaze-terraform-infra-core
# ─────────────────────────────────────────────────────────────

terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.15.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52.0"
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ── Remote State: Network ──
data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = "${var.namespace}-${var.client_key}-tfstate"
    prefix = "infra/${var.project_key}/${var.stage}/network.tfstate"
  }
}

locals {
  admin_hostname = var.stage == "prod" ? "admin-gcp.${var.domain_root}" : "admin-gcp-${var.stage}.${var.domain_root}"
}

# ── Environment App Module ──
module "environment_app" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/compute/environment-app?ref=v2.1.1"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  namespace      = var.namespace
  client_key     = var.client_key
  project_key    = var.project_key
  stage          = var.stage

  # Networking
  vpc_id                = try(data.terraform_remote_state.network.outputs.vpc_id, "")
  vpc_name              = try(data.terraform_remote_state.network.outputs.vpc_name, "")
  artifact_registry_url = try(data.terraform_remote_state.network.outputs.artifact_registry_url, "")
  artifact_registry_id  = try(data.terraform_remote_state.network.outputs.artifact_registry_id, "")
  use_vpc_connector     = var.use_vpc_connector
  vpc_connector_cidr    = var.vpc_connector_cidr

  # API
  api_image                 = var.api_image
  api_port                  = var.api_port
  api_cpu                   = var.api_cpu
  api_memory                = var.api_memory
  api_min_instances         = var.api_min_instances
  api_max_instances         = var.api_max_instances
  api_health_path           = var.api_health_path
  api_env_vars              = var.api_env_vars
  api_allow_unauthenticated = var.api_allow_unauthenticated

  # Frontend
  deploy_frontend                = var.deploy_frontend
  frontend_image                 = var.frontend_image
  frontend_port                  = var.frontend_port
  frontend_cpu                   = var.frontend_cpu
  frontend_memory                = var.frontend_memory
  frontend_min_instances         = var.frontend_min_instances
  frontend_max_instances         = var.frontend_max_instances
  frontend_env_vars              = var.frontend_env_vars
  frontend_allow_unauthenticated = var.frontend_allow_unauthenticated

  # Storage
  enable_storage       = var.enable_storage
  storage_cors_origins = var.storage_cors_origins

  # DNS — gated by enable_custom_domains (requires GCP domain verification)
  # Note: cloudflare_api_token must always be valid (provider validates at init)
  domain_root        = var.enable_custom_domains ? var.domain_root : ""
  create_dns_records = var.enable_custom_domains

  api_subdomain_override      = "api-gcp-${var.stage}"
  frontend_subdomain_override = "gcp-${var.stage}"

  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_api_token = var.cloudflare_api_token
}

# ── Cloudflare Pages Project (Admin) ──
module "pages_project_admin" {
  count  = var.enable_custom_domains ? 1 : 0
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/pages-project?ref=v2.1.1"

  account_id        = var.cloudflare_account_id
  project_name      = "${var.namespace}-${var.client_key}-${var.project_key}-gcp-${var.stage}-admin"
  production_branch = "main"
}

# ── Cloudflare Pages Custom Domain ──
resource "cloudflare_pages_domain" "admin" {
  count        = var.enable_custom_domains ? 1 : 0
  account_id   = var.cloudflare_account_id
  project_name = module.pages_project_admin[0].name
  domain       = local.admin_hostname
}
