terraform {
  backend "s3" {}
  required_providers {
    # Only one entry per provider — aliases are declared in provider blocks below
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

# Primary region provider (eu-west-1 for all non-CloudFront resources)
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Client       = var.client_key
      Namespace    = var.namespace
      Project      = var.project_key
      Stage        = var.stage
      "Managed by" = var.tag_managed_by
      Support      = var.tag_support
      State        = var.tag_state
    }
  }
}

# CloudFront ACM certificates MUST be in us-east-1 — global CloudFront requirement
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Client       = var.client_key
      Namespace    = var.namespace
      Project      = var.project_key
      Stage        = var.stage
      "Managed by" = var.tag_managed_by
      Support      = var.tag_support
      State        = var.tag_state
    }
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# READ NETWORK LAYER OUTPUTS (ALB DNS, etc.)
# ──────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/multi-site/network.tfstate"
    region = var.aws_region
  }
}


locals {
  net = data.terraform_remote_state.network.outputs

  # CloudFront origin ID — references the shared ALB
  alb_origin_id = "multi-site-alb-${var.stage}"

  # CloudFront comment tag
  cf_comment = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-multi-site-cdn"

  # NOTE: CloudFront aliases must be real domain names (e.g. "www.site.com", "*.agency.com").
  # ECS service names from the app remote state are NOT domain names and cannot be used here.
  # Populate var.site_aliases in terraform.tfvars with the actual domain list.
}

# ──────────────────────────────────────────────────────────────────────────────
# ACM CERTIFICATE (us-east-1 — required for CloudFront)
# ──────────────────────────────────────────────────────────────────────────────
# Strategy: if you have ≤100 custom domains, one SAN cert covers all of them.
# For a wildcard setup (all sites are *.domain_root subdomains), set
# var.use_wildcard_cert = true and provide var.domain_root — much simpler.
resource "aws_acm_certificate" "multi_site" {
  provider = aws.us_east_1

  # Wildcard cert if all domains are subdomains. SANs if custom domains.
  domain_name               = var.use_wildcard_cert ? "*.${var.domain_root}" : var.primary_domain
  subject_alternative_names = var.use_wildcard_cert ? [var.domain_root] : var.site_aliases

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# LAMBDA@EDGE — Image Resize (Sharp)
# Deployed once · serves all 120+ sites
# ──────────────────────────────────────────────────────────────────────────────
module "image_resize" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/image-resize?ref=v1.47.0"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  name      = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-multi-site"
  s3_bucket = var.images_s3_bucket_name

  # Image resize limits — conservative defaults for small sites
  max_width  = 2560
  max_height = 2560
  quality    = 80
}

# ──────────────────────────────────────────────────────────────────────────────
# CLOUDFRONT DISTRIBUTION
# 1 distribution · all site domains as aliases · ALB as origin
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_cloudfront_distribution" "multi_site" {
  comment         = local.cf_comment
  enabled         = true
  is_ipv6_enabled = true
  price_class     = var.cloudfront_price_class # PriceClass_100 = EU+US only (cheapest)
  aliases         = var.site_aliases           # populated from var — see terraform.tfvars

  # ── ORIGIN: Shared ALB ────────────────────────────────────────────────────
  origin {
    domain_name = local.net.alb_dns_name
    origin_id   = local.alb_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # Forward the original Host header so ALB host-based routing works correctly
    # Without this, ALB receives the CF distribution domain and no rule matches
    custom_header {
      name  = "X-Forwarded-Host"
      value = "forwarded"
    }
  }

  # ── DEFAULT BEHAVIOR: HTML (dynamic — never cache) ────────────────────────
  default_cache_behavior {
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    # AllViewer managed policy — forwards Host header to ALB
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    compress = true
  }

  # ── BEHAVIOR: JPG images — Lambda@Edge resize + 7-day cache ──────────────
  ordered_cache_behavior {
    path_pattern           = "*.jpg"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    compress               = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.image_resize.lambda_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern           = "*.jpeg"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.image_resize.lambda_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern           = "*.png"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.image_resize.lambda_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern           = "*.webp"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.image_resize.lambda_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern           = "*.gif"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.image_resize.lambda_arn
      include_body = false
    }
  }

  # ── BEHAVIOR: CSS — long TTL cache (365 days) ─────────────────────────────
  ordered_cache_behavior {
    path_pattern           = "*.css"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  # ── BEHAVIOR: JS — long TTL cache (365 days) ──────────────────────────────
  ordered_cache_behavior {
    path_pattern           = "*.js"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  # ── BEHAVIOR: Web Fonts — very long TTL ───────────────────────────────────
  ordered_cache_behavior {
    path_pattern           = "*.woff2"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = false # fonts already compressed
  }

  ordered_cache_behavior {
    path_pattern           = "*.woff"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = false
  }

  # ── BEHAVIOR: Health check — never cache ─────────────────────────────────
  ordered_cache_behavior {
    path_pattern           = "/health"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    compress               = true
  }

  # ── TLS ───────────────────────────────────────────────────────────────────
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.multi_site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name  = local.cf_comment
    Stack = "multi-site-cdn"
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# OUTPUTS
# ──────────────────────────────────────────────────────────────────────────────
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain — add as CNAME target in DNS for each site"
  value       = aws_cloudfront_distribution.multi_site.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.multi_site.id
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.multi_site.arn
}

output "image_resize_lambda_arn" {
  description = "Lambda@Edge Sharp function ARN (shared across all sites)"
  value       = module.image_resize.lambda_arn
}
