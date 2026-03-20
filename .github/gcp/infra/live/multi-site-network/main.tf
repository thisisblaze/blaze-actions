# ─────────────────────────────────────────────────────────────
# MULTI-SITE NETWORK (GCP)
# ─────────────────────────────────────────────────────────────
# Provisions the shared VPC, Subnets, and Artifact Registry 
# for the 120-website serverless fleet.
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

# ── Enable APIs ──

resource "google_project_service" "artifactregistry" {
  project            = var.gcp_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = var.gcp_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking" {
  project            = var.gcp_project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# ── Shared Network Infrastructure ──

module "network" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/networking/environment-network?ref=v2.1.1"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  namespace      = var.namespace
  client_key     = var.client_key
  project_key    = "multi-site"
  stage          = var.stage

  # Network CIDRs (/22 supports 1024 IPs for 120+ sites)
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  pods_cidr           = var.pods_cidr
  services_cidr       = var.services_cidr

  # Artifact Registry (Shared for the whole fleet)
  enable_artifact_registry     = true
  artifact_registry_keep_count = 50

  depends_on = [
    google_project_service.artifactregistry,
    google_project_service.compute,
    google_project_service.servicenetworking
  ]
}

# ─────────────────────────────────────────────────────────────
# OUTPUTS
# ─────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "VPC Network ID"
  value       = module.network.vpc_id
}

output "vpc_name" {
  description = "VPC Network Name"
  value       = module.network.vpc_name
}

output "private_subnet_id" {
  description = "Private Subnet Resource ID (for Direct VPC Egress)"
  value       = module.network.private_subnet_id
}

output "private_subnet_name" {
  description = "Private Subnet Name"
  value       = module.network.private_subnet_name
}

output "artifact_registry_url" {
  description = "Shared Artifact Registry URL"
  value       = module.network.artifact_registry_url
}

output "label_context" {
  description = "Context for child modules"
  value       = module.network.label_context
}
