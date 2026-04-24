# ── Core Configuration ──

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "project_key" {
  description = "The project key (e.g. thisisblaze)"
  type        = string
  default     = "thisisblaze"
}

variable "client_key" {
  description = "Short client identifier (e.g. b9)"
  type        = string
  default     = "b9"
}

variable "namespace" {
  description = "Namespace for resource naming (e.g. blaze)"
  type        = string
  default     = "blaze"
}

variable "stage" {
  description = "Deployment stage (dev, stage, prod)"
  type        = string
  default     = "dev"
}

# ── Cloudflare DNS Parity ──

variable "domain_root" {
  description = "Root domain (e.g. thisisblaze.uk). If empty, no DNS/SSL is configured."
  type        = string
  default     = ""
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for managing DNS"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}
