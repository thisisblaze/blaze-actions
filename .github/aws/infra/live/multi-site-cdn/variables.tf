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
# DOMAIN / TLS
# ──────────────────────────────────────────────────────────────────────────────
variable "domain_root" {
  type        = string
  description = "Root domain (e.g. 'youragency.com'). Used for wildcard cert: *.{domain_root}"
}

variable "primary_domain" {
  type        = string
  description = "Primary domain for SAN cert (only used when use_wildcard_cert = false)"
  default     = ""
}

variable "use_wildcard_cert" {
  type        = bool
  description = "true = wildcard cert *.{domain_root} (all sites are subdomains). false = SAN cert with site_aliases"
  default     = true
}

# ──────────────────────────────────────────────────────────────────────────────
# CLOUDFRONT ALIASES (site domains)
# ──────────────────────────────────────────────────────────────────────────────
variable "site_aliases" {
  type        = list(string)
  description = <<-EOT
    List of all site domains to add as CloudFront CNAME aliases.
    For wildcard setup: ["*.youragency.com"]
    For custom domains: ["www.clienta.com", "www.clientb.io", ...]
    These MUST match the ACM certificate SANs.
  EOT
  default     = []
}




# ──────────────────────────────────────────────────────────────────────────────
# IMAGE RESIZE
# ──────────────────────────────────────────────────────────────────────────────
variable "images_s3_bucket_name" {
  type        = string
  description = "S3 bucket for image resize cache and origin images. Leave empty to use ECS containers as image origin."
  default     = ""
}

# ──────────────────────────────────────────────────────────────────────────────
# CLOUDFRONT CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────
variable "cloudfront_price_class" {
  type        = string
  description = "CloudFront price class. PriceClass_100 = EU+US (cheapest). PriceClass_All = global."
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "cloudfront_price_class must be PriceClass_100, PriceClass_200, or PriceClass_All"
  }
}
