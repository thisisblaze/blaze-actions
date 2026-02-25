# ─── Standard Variables ─────────────────────────────────────

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "client_key" {
  description = "Client identifier (e.g. b9)"
  type        = string
  default     = "b9"
}

variable "project_key" {
  description = "Project identifier (e.g. thisisblaze)"
  type        = string
  default     = "thisisblaze"
}

# ─── Account Settings ──────────────────────────────────────

variable "container_insights" {
  description = "Default Container Insights setting: 'enabled' or 'disabled'"
  type        = string
  default     = "enabled"
}
