variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "client_key" {
  description = "Client identifier (e.g., b9)"
  type        = string
  default     = "b9"
}

variable "project_key" {
  description = "Project identifier (e.g., thisisblaze)"
  type        = string
  default     = "thisisblaze"
}

variable "stage" {
  description = "Environment stage (stage)"
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "Namespace for resources (e.g., blaze)"
  type        = string
  default     = "blaze"
}

variable "tag_managed_by" {
  description = "Managed by tag"
  type        = string
  default     = "Terraform"
}

variable "tag_support" {
  description = "Support contact tag"
  type        = string
  default     = "infrastructure@thebyte9.com"
}

variable "tag_state" {
  description = "State tag"
  type        = string
  default     = "live"
}

# Feature flags
variable "enable_redis" {
  description = "Enable ElastiCache Redis deployment (disabled by default for cost savings)"
  type        = bool
  default     = false
}
