variable "project_key" {
  description = "The project key (e.g. thisisblaze)"
  type        = string
}

variable "client_key" {
  description = "The short client identifier (e.g., b9)."
  type        = string
}

variable "namespace" {
  description = "The namespace for resource naming (e.g. blaze)"
  type        = string
  default     = "blaze"
}

variable "stage" {
  description = "The deployment stage (dev, prod, etc.)"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "domain_root" {
  description = "Root domain (e.g. thisisblaze.uk)"
  type        = string
}

variable "basic_auth_credentials" {
  description = "List of base64-encoded username:password credentials for Basic Auth"
  type        = list(string)
  sensitive   = true
  default     = ["Ynl0ZTk6c3RhZ2luZw=="] # byte9:staging (default for DEV)
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "platform" {
  description = "Platform identifier (e.g. ecs)"
  type        = string
  default     = "ecs"
}

variable "tag_managed_by" {
  description = "Managed by tag"
  type        = string
  default     = "terraform"
}

variable "tag_support" {
  description = "Support email tag"
  type        = string
  default     = "support@byte9.io"
}

variable "tag_state" {
  description = "State tag (active/archived)"
  type        = string
  default     = "active"
}

variable "is_beta" {
  description = "Is this a beta environment?"
  type        = bool
  default     = false
}

variable "route53_parent_zone_id" {
  description = "Route53 parent zone ID"
  type        = string
  default     = ""
}

variable "sharp_layer_arn" {
  description = "Lambda Layer ARN for Sharp image processing"
  type        = string
  default     = ""
}

variable "deploy_stateful_services" {
  description = "Using stateful services?"
  type        = bool
  default     = false
}

variable "use_ecr_images" {
  description = "Use ECR images for stateful services?"
  type        = bool
  default     = false
}

variable "mongo_image_tag" {
  description = "Tag for Mongo image"
  type        = string
  default     = "latest"
}

variable "elasticsearch_image_tag" {
  description = "Tag for Elasticsearch image"
  type        = string
  default     = "9.2.2"
}

variable "kibana_image_tag" {
  description = "Tag for Kibana image"
  type        = string
  default     = "9.2.2"
}

variable "cloudfront_acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  type        = string
  default     = ""
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}


variable "branch_name" {
  description = "Name of the feature branch (if applicable)"
  type        = string
  default     = ""
}

# EC2 Capacity Provider (Hybrid ECS)
variable "ec2_cpu_architecture" {
  description = "CPU architecture for EC2 instances (X86_64 or ARM64)"
  type        = string
  default     = "ARM64"
}

variable "ec2_instance_types" {
  description = "EC2 instance types for the capacity provider"
  type        = list(string)
  default     = ["t4g.medium"]
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 0
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 3
}

variable "ec2_desired_size" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 1
}
