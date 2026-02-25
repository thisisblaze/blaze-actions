# ─────────────────────────────────────────────────────────────
# GCS Terraform State Backend (Bootstrap)
# ─────────────────────────────────────────────────────────────
# Run manually once to create the GCS bucket for Terraform state.
# After creation, all other stacks use `backend "gcs" {}`.
# ─────────────────────────────────────────────────────────────

terraform {
  # First run: local backend. After bucket exists, migrate to GCS.
  backend "local" {}

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
    managed-by = "terraform"
    namespace  = var.namespace
    client     = var.client_key
  }
}

# ── GCS Bucket for Terraform State ──
resource "google_storage_bucket" "tfstate" {
  name     = "${var.namespace}-${var.client_key}-tfstate"
  location = var.gcp_region
  project  = var.gcp_project_id

  # Prevent accidental deletion
  force_destroy = false

  # Enable versioning for state recovery
  versioning {
    enabled = true
  }

  # Lifecycle rule: keep 30 days of noncurrent versions
  lifecycle_rule {
    condition {
      num_newer_versions = 30
    }
    action {
      type = "Delete"
    }
  }

  uniform_bucket_level_access = true

  labels = {
    purpose = "terraform-state"
    stage   = "shared"
  }
}

output "bucket_name" {
  description = "GCS bucket name for Terraform state"
  value       = google_storage_bucket.tfstate.name
}
