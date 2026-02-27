variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "client_key" {
  description = "Client identifier (e.g. b9)"
  type        = string
}

variable "project_key" {
  description = "Project identifier (e.g. blaze)"
  type        = string
}

variable "namespace" {
  description = "Namespace identifier (e.g. blaze)"
  type        = string
  default     = "b9"
}

variable "stage" {
  description = "Stage/Environment (e.g. dev, prod)"
  type        = string
  default     = "dev-mini"
}

variable "platform" {
  description = "Platform identifier (e.g. aws)"
  type        = string
  default     = "aws"
}

variable "branch_name" {
  description = "Name of the feature branch (if applicable)"
  type        = string
  default     = ""
}

variable "deploy_stateful_services" {
  description = "Using stateful services?"
  type        = bool
  default     = false
}

variable "enable_tunnel" {
  description = "Enable Cloudflare Tunnel?"
  type        = bool
  default     = true # Enabled for DEV by default
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

variable "domain_root" {
  description = "Root domain for the environment"
  type        = string
  default     = "example.com"
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

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  type        = string
  default     = ""
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
  default     = "" # Optional if not using tunnel/cloudflare features
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}
