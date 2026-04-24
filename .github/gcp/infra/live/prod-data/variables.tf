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
  default     = "prod"
}

# ── Memorystore Redis ──

variable "enable_redis" {
  description = "Enable Memorystore Redis"
  type        = bool
  default     = false # Enable when needed for prod
}

variable "redis_tier" {
  description = "Redis tier: BASIC (no HA) or STANDARD_HA (replicated)"
  type        = string
  default     = "STANDARD_HA" # HA for prod
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB (minimum 1)"
  type        = number
  default     = 2 # Larger for prod
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
  default     = false # Enable when needed for prod
}

variable "cloud_sql_version" {
  description = "Cloud SQL database version"
  type        = string
  default     = "POSTGRES_15"
}

variable "cloud_sql_tier" {
  description = "Cloud SQL machine type"
  type        = string
  default     = "db-custom-2-7680" # 2 vCPU, 7.5 GB RAM for prod
}

variable "cloud_sql_ha" {
  description = "Enable high availability (Regional)"
  type        = bool
  default     = true # HA mandatory for prod
}

variable "cloud_sql_disk_size" {
  description = "Initial disk size in GB"
  type        = number
  default     = 50
}

variable "cloud_sql_deletion_protection" {
  description = "Prevent accidental deletion"
  type        = bool
  default     = true # Always protected in prod
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
