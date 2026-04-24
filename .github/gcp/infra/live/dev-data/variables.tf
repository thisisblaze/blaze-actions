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

# ── Memorystore Redis ──

variable "enable_redis" {
  description = "Enable Memorystore Redis (equivalent to ElastiCache)"
  type        = bool
  default     = false # Disabled by default in dev (cost saving)
}

variable "redis_tier" {
  description = "Redis tier: BASIC (no HA) or STANDARD_HA (replicated)"
  type        = string
  default     = "BASIC"
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB (minimum 1)"
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis version (e.g. REDIS_7_0)"
  type        = string
  default     = "REDIS_7_0"
}

# ── Cloud SQL PostgreSQL ──

variable "enable_cloud_sql" {
  description = "Enable Cloud SQL PostgreSQL"
  type        = bool
  default     = false # Disabled by default in dev
}

variable "cloud_sql_version" {
  description = "Cloud SQL database version"
  type        = string
  default     = "POSTGRES_15"
}

variable "cloud_sql_tier" {
  description = "Cloud SQL machine type (e.g. db-f1-micro, db-custom-1-3840)"
  type        = string
  default     = "db-f1-micro" # Smallest for dev
}

variable "cloud_sql_ha" {
  description = "Enable high availability (Regional) — use ZONAL for dev"
  type        = bool
  default     = false
}

variable "cloud_sql_disk_size" {
  description = "Initial disk size in GB"
  type        = number
  default     = 10
}

variable "cloud_sql_deletion_protection" {
  description = "Prevent accidental deletion"
  type        = bool
  default     = false # Allow deletion in dev
}

variable "cloud_sql_database_name" {
  description = "Default database name"
  type        = string
  default     = "blaze"
}

variable "cloud_sql_user" {
  description = "Database user"
  type        = string
  default     = "blaze_app"
}

variable "cloud_sql_password" {
  description = "Database password (pass via TF_VAR_cloud_sql_password or secret)"
  type        = string
  default     = ""
  sensitive   = true
}
