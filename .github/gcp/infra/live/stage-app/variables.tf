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
  default     = "stage"
}

# ── API Service ──

variable "api_image" {
  description = "Full image path for API (overrides AR default during deploy)"
  type        = string
  default     = ""
}

variable "api_port" {
  description = "Container port for API service"
  type        = number
  default     = 3001
}

variable "api_cpu" {
  description = "CPU limit for API (e.g. '1', '2')"
  type        = string
  default     = "1"
}

variable "api_memory" {
  description = "Memory limit for API (e.g. '512Mi', '1Gi')"
  type        = string
  default     = "1Gi" # More memory for stage
}

variable "api_min_instances" {
  description = "Minimum instances (0 = scale to zero)"
  type        = number
  default     = 0 # Enforce scale-to-zero for stage
}

variable "api_max_instances" {
  description = "Maximum instances for API"
  type        = number
  default     = 5
}

variable "api_health_path" {
  description = "Health check path for API (empty = TCP probe)"
  type        = string
  default     = ""
}

variable "api_env_vars" {
  description = "Environment variables for API container"
  type        = map(string)
  default     = {}
}

variable "api_allow_unauthenticated" {
  description = "Allow public access to API"
  type        = bool
  default     = true
}

# ── Frontend Service ──

variable "deploy_frontend" {
  description = "Deploy the frontend service"
  type        = bool
  default     = true
}

variable "frontend_image" {
  description = "Full image path for Frontend (overrides AR default during deploy)"
  type        = string
  default     = ""
}

variable "frontend_port" {
  description = "Container port for Frontend service"
  type        = number
  default     = 3000
}

variable "frontend_cpu" {
  description = "CPU limit for Frontend"
  type        = string
  default     = "1"
}

variable "frontend_memory" {
  description = "Memory limit for Frontend"
  type        = string
  default     = "512Mi" # More memory for stage
}

variable "frontend_min_instances" {
  description = "Minimum instances for Frontend (0 = scale to zero)"
  type        = number
  default     = 0 # Enforce scale-to-zero for stage
}

variable "frontend_max_instances" {
  description = "Maximum instances for Frontend"
  type        = number
  default     = 5
}

variable "frontend_env_vars" {
  description = "Environment variables for Frontend container"
  type        = map(string)
  default     = {}
}

variable "frontend_allow_unauthenticated" {
  description = "Allow public access to Frontend"
  type        = bool
  default     = true
}

# ── VPC Connector ──

variable "use_vpc_connector" {
  description = "Create VPC Access Connector for Cloud Run → private resources"
  type        = bool
  default     = true # Enabled for stage (private data access)
}

variable "vpc_connector_cidr" {
  description = "CIDR for VPC Access Connector (must not overlap with existing subnets)"
  type        = string
  default     = "10.18.0.0/28"
}

# ── Storage ──

variable "enable_storage" {
  description = "Create GCS storage bucket"
  type        = bool
  default     = true
}

variable "storage_cors_origins" {
  description = "CORS allowed origins for the storage bucket"
  type        = list(string)
  default     = ["*"]
}

# ── DNS & Domain Mapping ──

variable "domain_root" {
  description = "Root domain (e.g. thisisblaze.com)"
  type        = string
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_custom_domains" {
  description = "Enable custom domain mapping (requires GCP domain verification)"
  type        = bool
  default     = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID (for Pages project)"
  type        = string
  default     = ""
}
