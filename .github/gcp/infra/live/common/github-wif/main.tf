# ─────────────────────────────────────────────────────────────
# GitHub Workload Identity Federation (GCP ↔ GitHub Actions)
# ─────────────────────────────────────────────────────────────
# Equivalent to AWS common/github-oidc.
# Creates:
#   - Workload Identity Pool
#   - Workload Identity Provider (GitHub OIDC)
#   - Service Account with repo-scoped impersonation
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
    managed-by = "terraform"
    namespace  = var.namespace
    client     = var.client_key
  }
}

# ── Workload Identity Pool ──
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "${var.namespace}-github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions CI/CD"
}

# ── Workload Identity Provider (GitHub OIDC) ──
# Allows both GitHub orgs (thebyte9 + thisisblaze) to authenticate
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Allow any org in the trusted list
  attribute_condition = join(" || ", [
    for org in var.github_orgs : "assertion.repository_owner == '${org}'"
  ])

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ── Service Account for GitHub Actions ──
resource "google_service_account" "github_actions" {
  project      = var.gcp_project_id
  account_id   = "${var.namespace}-github-actions"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions CI/CD via Workload Identity Federation"
}

# ── Allow federated auth from all configured repos ──
resource "google_service_account_iam_member" "github_actions_wif" {
  for_each = toset(var.github_repos)

  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
}

# ── Grant least-privilege IAM roles ──
# Replaces the overly broad roles/editor with specific roles needed for CI/CD
resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset(var.service_account_roles)

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# ── Outputs ──
output "workload_identity_provider" {
  description = "Full resource name for the WIF provider (use as GCP_WORKLOAD_IDENTITY_PROVIDER secret)"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  description = "Service account email (use as GCP_SERVICE_ACCOUNT secret)"
  value       = google_service_account.github_actions.email
}

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = google_iam_workload_identity_pool.github.workload_identity_pool_id
}
