# ─────────────────────────────────────────────────────────────
# NETWORK INFRASTRUCTURE (GCP DEV)
# ─────────────────────────────────────────────────────────────
# Uses reusable module from blaze-terraform-infra-core
# ─────────────────────────────────────────────────────────────

terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
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
    managed-by = var.tag_managed_by
  }
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region

  default_labels = {
    client     = var.client_key
    namespace  = var.namespace
    project    = var.project_key
    stage      = var.stage
    managed-by = var.tag_managed_by
  }
}

# ── Enable Artifact Registry API ──
resource "google_project_service" "artifactregistry" {
  project            = var.gcp_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# ── Enable Compute API ──
resource "google_project_service" "compute" {
  project            = var.gcp_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# ── Enable Service Networking API ──
resource "google_project_service" "servicenetworking" {
  project            = var.gcp_project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# ── Enable Container API ──
resource "google_project_service" "container" {
  project            = var.gcp_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# ── Environment Network Module ──
module "environment_network" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/networking/environment-network?ref=v2.1.1"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  namespace      = var.namespace
  client_key     = var.client_key
  project_key    = var.project_key
  stage          = var.stage

  # Network CIDRs
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  pods_cidr           = var.pods_cidr
  services_cidr       = var.services_cidr

  # Artifact Registry
  enable_artifact_registry     = true
  artifact_registry_keep_count = 10

  depends_on = [
    google_project_service.artifactregistry,
    google_project_service.compute,
    google_project_service.servicenetworking,
    google_project_service.container
  ]
}
