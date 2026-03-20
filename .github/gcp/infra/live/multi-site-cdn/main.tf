# ─────────────────────────────────────────────────────────────
# SHARED GLOBAL LOAD BALANCER (GCP)
# ─────────────────────────────────────────────────────────────
# This "Common Ingress" wires up 120+ Cloud Run services 
# through a single Global HTTPS LB with host-based routing.
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

data "terraform_remote_state" "app" {
  backend = "gcs"
  config = {
    bucket = "${var.namespace}-${var.client_key}-terraform-state"
    prefix = "gcp/${var.stage}/multi-site-app"
  }
}

# ── Shared Global Ingress (CDN Stack) ──

module "cdn" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/cdn/global-https-lb?ref=v2.1.1"

  context        = data.terraform_remote_state.network.outputs.label_context
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  # ── Backend Services (The Fleet) ──
  backend_services = data.terraform_remote_state.app.outputs.backend_services

  # ── Routing (Host-based ↔ 120 NEGs) ──
  host_rules    = data.terraform_remote_state.app.outputs.host_rules
  path_matchers = data.terraform_remote_state.app.outputs.path_matchers

  # ── SSL Termination ──
  # Recommended: Cloudflare Edge Terminate. 
  # Use Google Managed Certificates as fallback for non-Cloudflare domains.
  managed_ssl_domains = data.terraform_remote_state.app.outputs.managed_ssl_domains

  # Default landing backend (first site in the fleet)
  default_backend = data.terraform_remote_state.app.outputs.backend_services[0].name
}

# ─────────────────────────────────────────────────────────────
# OUTPUTS
# ─────────────────────────────────────────────────────────────

output "lb_ip" {
  description = "The Shared Global Anycast IP for all 120 sites."
  value       = module.cdn.lb_ip_address
}
