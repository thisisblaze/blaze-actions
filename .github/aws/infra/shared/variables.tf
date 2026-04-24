variable "namespace" {
  description = "Resource naming namespace (e.g. blaze)"
  type        = string
  default     = "blaze"
}

variable "project_key" {
  description = "Project key"
  type        = string
}

variable "stage" {
  description = "Stage name (e.g. dev, stage, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}
