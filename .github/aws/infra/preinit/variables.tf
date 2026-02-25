variable "client_key" {
  type        = string
  description = "Client key (e.g. b9)"
}

variable "project_key" {
  type        = string
  description = "Project key (e.g. thisisblaze)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. dev, stage, prod)"
}

variable "namespace" {
  type        = string
  default     = "blaze"
  description = "Namespace (e.g. blaze)"
}

variable "platform" {
  type        = string
  default     = "ecs"
  description = "Platform identifier (ecs, elastic-beanstalk, etc.)"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}