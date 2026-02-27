variable "project_key" {
  description = "The project key (e.g. thisisblaze)"
  type        = string
  default     = "thisisblaze"
}

variable "client_key" {
  description = "The short client identifier (e.g., b9)."
  type        = string
  default     = "b9"
}

variable "platform" {
  description = "The platform identifier (e.g. ecs)"
  type        = string
  default     = "ecs"
}

variable "tag_managed_by" {
  type        = string
  description = "Managed by tag"
  default     = "terraform"
}

variable "tag_support" {
  type        = string
  description = "Support email tag"
  default     = "support@byte9.io"
}

variable "tag_state" {
  type        = string
  description = "State tag (e.g. active, archived)"
  default     = "active"
}

variable "namespace" {
  description = "The namespace for resource naming (e.g. blaze)"
  type        = string
  default     = "blaze"
}

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "eu-west-1"
}

variable "stage" {
  description = "The deployment stage (dev, prod, etc.)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS listener"
  type        = string
  default     = ""
}

# Added for compatibility with stage/prod structure, though unused if not using ALB
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_alb" {
  description = "Enable Application Load Balancer (ALB) for Dev environment. If false, uses Cloudflare Tunnel."
  type        = bool
  default     = false
}

# Added Cloudflare Variables (Audit 2025-12-19)
variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "domain_root" {
  description = "Root domain (e.g. thisisblaze.uk)"
  type        = string
}

# --------------------------------------------------------------------------------
# EC2 CAPACITY PROVIDER (Hybrid ECS — Feb 2026)
# --------------------------------------------------------------------------------
variable "enable_ec2" {
  description = "Enable EC2 capacity provider for hybrid Fargate/EC2 deployment"
  type        = bool
  default     = true
}

variable "ec2_instance_types" {
  description = "EC2 instance types for the capacity provider"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ec2_cpu_architecture" {
  description = "CPU architecture: X86_64 or ARM64"
  type        = string
  default     = "X86_64"
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 0
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 2
}

variable "ec2_desired_size" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 1
}
