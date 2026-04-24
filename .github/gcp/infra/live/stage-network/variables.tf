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
  default     = "stage"
}

variable "tag_managed_by" {
  description = "Managed by label value"
  type        = string
  default     = "terraform"
}

# ── Network CIDRs (offset from dev) ──

variable "private_subnet_cidr" {
  description = "CIDR for the private (application) subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "pods_cidr" {
  description = "Secondary CIDR for GKE/Cloud Run pods"
  type        = string
  default     = "10.11.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR for GKE/Cloud Run services"
  type        = string
  default     = "10.12.0.0/20"
}
