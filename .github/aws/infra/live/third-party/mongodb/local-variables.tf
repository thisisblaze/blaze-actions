
variable "atlas_public_key" {
  description = "MongoDB Atlas Public Key"
  type        = string
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private Key"
  type        = string
  sensitive   = true
}

variable "atlas_org_id" {
  description = "The Atlas Organization ID"
  type        = string
}

variable "atlas_project_id" {
  description = "Existing Atlas Project ID (optional). If set, Terraform will NOT create a new Atlas project."
  type        = string
  default     = ""
}

variable "cluster_tier" {
  description = "The Atlas Cluster Tier (M2, M10, M30, etc)"
  type        = string
  default     = "M10"
}

variable "is_paused" {
  description = "Whether to pause the cluster (cost saving)"
  type        = bool
  default     = false
}

# Map AWS Regions to Atlas Regions
variable "atlas_region_map" {
  type = map(string)
  default = {
    "eu-west-1" = "EU_WEST_1"
    "us-east-1" = "US_EAST_1"
  }
}

variable "trusted_ip_list" {
  description = "List of trusted IP addresses/CIDR blocks for MongoDB Atlas"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow all by default, restrict in production
}
