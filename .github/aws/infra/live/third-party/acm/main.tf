terraform {
  backend "s3" {}
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
  }
}

# ============================================================================
# AWS PROVIDER CONFIGURATION - CLOUDFRONT CERTIFICATE REGION
# ============================================================================
# ⚠️  CRITICAL: CloudFront ACM certificates MUST be in us-east-1
# ============================================================================
#
# WHY us-east-1 IS REQUIRED:
# -------------------------
# CloudFront is a GLOBAL service that distributes content from edge locations
# worldwide. AWS requires ALL CloudFront SSL/TLS certificates to be created
# in the us-east-1 region, regardless of where your infrastructure is located.
#
# This is an AWS ARCHITECTURAL REQUIREMENT, not a configuration choice.
#
# YOUR INFRASTRUCTURE LOCATION: eu-west-1 (London, from vars/blaze-env.json)
# YOUR ACM CERTIFICATES:
#   - ALB Certificate (Regional):  eu-west-1 (same region as infrastructure)
#   - CloudFront Certificate:      us-east-1 (REQUIRED by AWS for CloudFront)
#
# DO NOT CHANGE THIS REGION - IT WILL BREAK CLOUDFRONT HTTPS
#
# For more information:
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html
# ============================================================================
provider "aws" {
  region = "us-east-1" # AWS requirement for CloudFront certificates (DO NOT CHANGE)
  alias  = "us_east_1"
}

# Regional provider for ALB certificate (uses main infrastructure region)
provider "aws" {
  region = var.aws_region # From vars/blaze-env.json (eu-west-1)
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# -------------------------------------------------------------------------
# AWS ACM SSL CERTIFICATES (STAGE/PROD ONLY)
# -------------------------------------------------------------------------
# ⚠️  IMPORTANT: This resource is for STAGE and PROD environments ONLY.
#     DEV environments use Cloudflare Tunnel (no ALB, no ACM needed).
#     See: .github/aws/infra/live/third-party/cloudflare/ for DEV setup.
#
# Purpose:
#   - Provides SSL/TLS certificates for Application Load Balancer (ALB)
#   - Required for HTTPS traffic in STAGE and PROD environments
#   - Creates certificates in both regional (ALB) and us-east-1 (CloudFront)
#
# Usage:
#   - Deploy this stack ONLY for STAGE or PROD environments
#   - Do NOT deploy for DEV (Cloudflare Tunnel handles SSL)
#   - Certificates are validated via DNS records in Cloudflare
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# 1. Regional Certificate (For ALB in STAGE/PROD)
# -------------------------------------------------------------------------
resource "aws_acm_certificate" "main" {
  domain_name = var.domain_root
  subject_alternative_names = [
    "*.${var.domain_root}"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------------
# 2. CloudFront Certificate (Must be us-east-1)
# -------------------------------------------------------------------------
resource "aws_acm_certificate" "cloudfront" {
  provider    = aws.us_east_1
  domain_name = var.domain_root
  subject_alternative_names = [
    "*.${var.domain_root}"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------------
# 3. DNS Validation (Cloudflare)
# -------------------------------------------------------------------------
# NOTE: Both regional and cloudfront ACM certs for the same domain share
# the SAME DNS validation CNAME. We create ONE record per domain.
# Cloudflare v5 removed allow_overwrite, so duplicates are not allowed.
# The pre_apply_script imports the existing record into this new address.
# -------------------------------------------------------------------------
resource "cloudflare_dns_record" "acm_validation" {
  for_each = toset([var.domain_root])

  zone_id = var.cloudflare_zone_id

  name = (
    [
      for dvo in tolist(aws_acm_certificate.main.domain_validation_options) :
      trimsuffix(trimsuffix(dvo.resource_record_name, "."), ".${var.domain_root}")
      if dvo.domain_name == each.value || dvo.domain_name == "*.${each.value}"
    ][0]
  )

  type = (
    [
      for dvo in tolist(aws_acm_certificate.main.domain_validation_options) :
      dvo.resource_record_type
      if dvo.domain_name == each.value || dvo.domain_name == "*.${each.value}"
    ][0]
  )

  content = (
    [
      for dvo in tolist(aws_acm_certificate.main.domain_validation_options) :
      dvo.resource_record_value
      if dvo.domain_name == each.value || dvo.domain_name == "*.${each.value}"
    ][0]
  )

  ttl     = 60
  proxied = false
}

# -------------------------------------------------------------------------
# 4. Wait for Validation
# -------------------------------------------------------------------------
# Both certs share the same validation record — reference the single record
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for k, record in cloudflare_dns_record.acm_validation :
    endswith(record.name, var.domain_root) ? record.name : "${record.name}.${var.domain_root}"
  ]
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [
    for k, record in cloudflare_dns_record.acm_validation :
    endswith(record.name, var.domain_root) ? record.name : "${record.name}.${var.domain_root}"
  ]
}

# -------------------------------------------------------------------------
# State Migration: Cloudflare Provider v5
# -------------------------------------------------------------------------
# Old config had two DNS records (regional|domain and cloudfront|domain)
# pointing to the same CNAME. Now deduplicated to one per domain.
# The pre_apply_script (.github/scripts/import-existing-resources.sh):
#   1. Removes old cloudflare_record entries from state (v5 can't decode them)
#   2. Removes cloudflare_dns_record entries with old for_each keys
#   3. Imports the existing DNS record with the new "thisisblaze.uk" key
# -------------------------------------------------------------------------
