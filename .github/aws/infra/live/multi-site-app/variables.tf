variable "namespace" {
  type    = string
  default = "blaze"
}

variable "client_key" {
  type = string
}

variable "project_key" {
  type = string
}

variable "stage" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "platform" {
  type    = string
  default = "ecs"
}

variable "tag_managed_by" {
  type    = string
  default = "terraform"
}

variable "tag_support" {
  type    = string
  default = "support@byte9.io"
}

variable "tag_state" {
  type    = string
  default = "active"
}

# ──────────────────────────────────────────────────────────────────────────────
# SITES MAP — the primary input
# ──────────────────────────────────────────────────────────────────────────────
variable "sites" {
  description = <<-EOT
    Map of all sites to deploy. Each key is a unique site slug (lowercase, hyphens).

    tier = "standard" → EC2 ARM64 Graviton ASG, binpacked, cpu=256, mem=512, min=0, max=2
    tier = "premium"  → Fargate ARM64, instant scale, cpu=1024, mem=2048, min=2, max=20, CodeDeploy B/G

    See module docs for full list of per-site overrideable fields.
  EOT

  type = map(object({
    domain               = string
    tier                 = string
    container_image      = string
    cpu                  = optional(number)
    memory               = optional(number)
    min_capacity         = optional(number)
    max_capacity         = optional(number)
    container_port       = optional(number)
    enable_codedeploy    = optional(bool)
    health_check_path    = optional(string)
    health_check_matcher = optional(string)
    environment          = optional(list(object({ name = string, value = string })), [])
    secrets              = optional(list(object({ name = string, valueFrom = string })), [])
  }))
}

variable "listener_rule_priority_base" {
  type        = number
  description = "Base ALB listener rule priority. Rules are base+index(site). Default 100 is safe for a fresh ALB."
  default     = 100
}

variable "assets_bucket_arn" {
  type        = string
  description = "ARN of shared S3 assets bucket. Each site's task role gets scoped access to its own prefix. Leave empty to skip."
  default     = ""
}
