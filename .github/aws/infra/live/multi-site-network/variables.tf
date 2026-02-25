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

variable "nat_strategy" {
  type        = string
  default     = "NONE"
  description = "NAT Gateway strategy: NONE (dev/stage), SINGLE (prod — 1 NAT GW in eu-west-1a)"

  validation {
    condition     = contains(["NONE", "SINGLE", "GATEWAY"], var.nat_strategy)
    error_message = "nat_strategy must be NONE, SINGLE, or GATEWAY."
  }
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the ALB HTTPS :443 listener. Must cover *.{domain_root}."
  default     = ""
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cloudflare_zone_id" {
  type    = string
  default = ""
}

variable "domain_root" {
  type    = string
  default = ""
}

# ──────────────────────────────────────────────────────────────────────────────
# EC2 GRAVITON ASG SIZING
# ──────────────────────────────────────────────────────────────────────────────
variable "ec2_asg_min" {
  type        = number
  description = "Minimum EC2 instances in the Graviton ASG"
  default     = 1
}

variable "ec2_asg_max" {
  type        = number
  description = "Maximum EC2 instances in the Graviton ASG. Set to 20+ for 120 sites."
  default     = 20
}

variable "ec2_asg_desired" {
  type        = number
  description = "Initial desired count for the Graviton ASG"
  default     = 2
}
