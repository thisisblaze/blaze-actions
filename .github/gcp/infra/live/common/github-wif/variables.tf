variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "namespace" {
  description = "Namespace for resource naming (e.g. blaze)"
  type        = string
  default     = "blaze"
}

variable "client_key" {
  description = "Short client identifier (e.g. b9)"
  type        = string
  default     = "b9"
}

# ── GitHub Configuration ──

variable "github_orgs" {
  description = "List of GitHub organizations allowed to authenticate via WIF"
  type        = list(string)
  default     = ["thebyte9", "thisisblaze"]
}

variable "github_repos" {
  description = "List of GitHub repos (org/repo format) allowed to impersonate the service account"
  type        = list(string)
  default     = ["thebyte9/blaze-template-deploy", "thisisblaze/blaze-actions"]
}

# ── IAM Roles ──

variable "service_account_roles" {
  description = "IAM roles to grant the GitHub Actions service account (least-privilege)"
  type        = list(string)
  default = [
    # Compute & Deployment
    "roles/run.admin",             # Cloud Run: deploy, manage services
    "roles/compute.networkAdmin",  # VPC, subnets, firewall, NAT, Cloud Router
    "roles/compute.securityAdmin", # Firewall rules, SSL policies
    # Storage & Registry
    "roles/artifactregistry.admin", # Push/pull Docker images
    "roles/storage.admin",          # GCS buckets (TF state, assets)
    # Security & IAM
    "roles/iam.serviceAccountUser",          # Attach SA to Cloud Run / Compute
    "roles/iam.serviceAccountAdmin",         # Manage service accounts via TF
    "roles/resourcemanager.projectIamAdmin", # Manage IAM bindings via TF
    # Networking
    "roles/dns.admin", # Cloud DNS (if used)
    # Logging & Monitoring (read-only for health checks)
    "roles/logging.viewer",    # View logs
    "roles/monitoring.viewer", # View metrics
  ]
}
