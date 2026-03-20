# ─────────────────────────────────────────────────────────────
# MULTI-SITE APPLICATION FLEET (GCP)
# ─────────────────────────────────────────────────────────────
# Manages the Cloud Run compute layer for 120+ sites.
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
}

# ── Data Sources ──

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = "${var.namespace}-${var.client_key}-terraform-state"
    prefix = "gcp/${var.stage}/multi-site-network"
  }
}

# ── Cloud Run Multi-Site Fleet ──

module "app_fleet" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/compute/multi-site-app?ref=v2.1.1"

  context        = data.terraform_remote_state.network.outputs.label_context
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  # Networking (Direct VPC Egress to Private Subnet)
  subnet_id = data.terraform_remote_state.network.outputs.private_subnet_id

  # The Fleet Configuration
  sites = var.sites
}

# ── DNS Automation (Cloudflare) ──

module "cloudflare_records" {
  source   = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/dns-records?ref=v2.1.1"
  for_each = { for k, v in var.sites : k => v if v.domain != "" }

  # Wait, wait... for multi-site, many domains might be in DIFFERENT zones.
  # The simple dns-records module assumes a single zone.
  # For 120 sites, we usually point them all to the Shared LB IP.
  # We should do this in a separate cdn stack.
}

# ─────────────────────────────────────────────────────────────
# OUTPUTS
# ─────────────────────────────────────────────────────────────

output "backend_services" {
  description = "Backend services configuration for the CDN stack."
  value       = module.app_fleet.backend_services
}

output "host_rules" {
  description = "URL Map host rules."
  value       = module.app_fleet.host_rules
}

output "path_matchers" {
  description = "URL Map path matchers."
  value       = module.app_fleet.path_matchers
}

output "managed_ssl_domains" {
  description = "Domains for SSL certificates."
  value       = module.app_fleet.managed_ssl_domains
}
