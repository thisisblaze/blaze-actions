# ─────────────────────────────────────────────────────────────
# CDN + GLOBAL LOAD BALANCER (GCP DEV)
# ─────────────────────────────────────────────────────────────
# Creates:
#   - Global HTTPS LB with Cloud CDN and URL Map path routing
#   - Cloud Armor (WAF) with basic rate limiting
#   - Image Resize Cloud Function + CDN
#   - Routes: /api/*, /graphql → API, /convert/* → Image Resize, /* → Frontend
#
# Equivalent of: AWS CloudFront + ALB behaviors + Lambda@Edge
# ─────────────────────────────────────────────────────────────

terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.15.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.15.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  default_labels = {
    client     = var.client_key
    namespace  = var.namespace
    project    = var.project_key
    stage      = var.stage
    managed-by = "terraform"
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ── Remote State: App Stack (for Cloud Run service names) ──
data "terraform_remote_state" "app" {
  backend = "gcs"
  config = {
    bucket = "${var.namespace}-${var.client_key}-tfstate"
    prefix = "infra/${var.project_key}/${var.stage}/app.tfstate"
  }
}

# ── Label ──
module "label" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/common/label?ref=v1.46.0"

  namespace  = var.namespace
  stage      = var.stage
  name       = "cdn"
  attributes = []
  tags       = {}
}

# ─────────────────────────────────────────────────────────────
# API ENABLEMENT (required for Cloud Functions gen2 + CDN)
# ─────────────────────────────────────────────────────────────

resource "google_project_service" "cloudfunctions" {
  project            = var.gcp_project_id
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "eventarc" {
  project            = var.gcp_project_id
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild" {
  project            = var.gcp_project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  project            = var.gcp_project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# ─────────────────────────────────────────────────────────────
# CLOUD ARMOR (WAF) — Basic rate limiting for dev
# ─────────────────────────────────────────────────────────────

module "cloud_armor" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/security/cloud-armor?ref=v1.46.0"

  context        = module.label.context
  gcp_project_id = var.gcp_project_id

  # Dev: rate limiting only, no OWASP rules
  enable_owasp_rules               = false
  enable_rate_limiting             = true
  rate_limit_requests_per_interval = 200
  rate_limit_interval_seconds      = 60
}

# ─────────────────────────────────────────────────────────────
# IMAGE RESIZE (Cloud Function gen2 + CDN)
# ─────────────────────────────────────────────────────────────

module "image_resize" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/compute/image-resize?ref=v1.46.0"

  context        = module.label.context
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  bucket_name        = "${var.namespace}-${var.client_key}-${var.stage}-image-resize"
  source_bucket_name = try(data.terraform_remote_state.app.outputs.storage_bucket_name, "")
  force_destroy      = true # Dev only

  # CDN disabled here — the global LB handles CDN for image resize
  enable_cdn = false

  # Dev: scale to zero
  function_min_instances = 0
  function_max_instances = 5

  depends_on = [
    google_project_service.cloudfunctions,
    google_project_service.eventarc,
    google_project_service.cloudbuild,
    google_project_service.run
  ]
}

# ─────────────────────────────────────────────────────────────
# GLOBAL HTTPS LB + CLOUD CDN (CloudFront Equivalent)
# ─────────────────────────────────────────────────────────────

module "global_lb" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/cdn/global-https-lb?ref=v1.46.0"

  context        = module.label.context
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  backend_services = [
    # API — dynamic, no CDN cache
    {
      name            = "api"
      type            = "cloud_run"
      service_name    = try(data.terraform_remote_state.app.outputs.api_service_name, "blaze-api")
      enable_cdn      = false
      timeout_sec     = 60
      security_policy = module.cloud_armor.policy_self_link
    },
    # Frontend — static assets cached via CDN
    {
      name            = "frontend"
      type            = "cloud_run"
      service_name    = try(data.terraform_remote_state.app.outputs.frontend_service_name, "blaze-frontend")
      enable_cdn      = true
      cdn_cache_mode  = "USE_ORIGIN_HEADERS"
      cdn_default_ttl = 3600  # 1 hour
      cdn_max_ttl     = 86400 # 24 hours
      security_policy = module.cloud_armor.policy_self_link
    },
    # Image Resize — CDN with long TTL
    {
      name                     = "image-resize"
      type                     = "cloud_function"
      service_name             = module.image_resize.function_name
      enable_cdn               = true
      cdn_cache_mode           = "USE_ORIGIN_HEADERS"
      cdn_default_ttl          = 86400    # 24 hours
      cdn_max_ttl              = 31536000 # 1 year
      cdn_include_query_string = true     # Cache based on w, h, f, q params
      security_policy          = module.cloud_armor.policy_self_link
    }
  ]

  default_backend = "frontend"

  # Path routing — equivalent to CloudFront ordered_cache_behaviors
  host_rules = [
    {
      hosts        = ["api-${var.stage}.${var.domain_root}", "api-gcp-${var.stage}.${var.domain_root}"]
      path_matcher = "api"
    },
    {
      hosts        = ["*"]
      path_matcher = "frontend"
    }
  ]

  path_matchers = [
    {
      name            = "api"
      default_backend = "api"
      path_rules      = []
    },
    {
      name            = "frontend"
      default_backend = "frontend"
      path_rules = [
        # Frontend paths
        { paths = ["/api/*", "/graphql"], backend = "api" }, # Proxies Same-Origin `/api/*` requests for CORS
        { paths = ["/convert/*"], backend = "image-resize" }
      ]
    }
  ]

  # Dev: Enable SSL for gcp-dev sub-domain (AWS parity)
  managed_ssl_domains  = var.domain_root != "" ? ["gcp-dev.${var.domain_root}", "api-gcp-dev.${var.domain_root}"] : []
  enable_http_redirect = true

  enable_logging  = true
  log_sample_rate = 1.0 # Full logging in dev
}

# ─────────────────────────────────────────────────────────────
# OUTPUTS
# ─────────────────────────────────────────────────────────────

output "lb_ip_address" {
  description = "Global LB IP address"
  value       = module.global_lb.lb_ip_address
}

output "lb_url" {
  description = "Load balancer URL"
  value       = module.global_lb.lb_url
}

output "image_resize_function_url" {
  description = "Direct URL for image resize function (bypass CDN)"
  value       = module.image_resize.function_url
}

output "cloud_armor_policy" {
  description = "Cloud Armor WAF policy self_link"
  value       = module.cloud_armor.policy_self_link
}

# ─────────────────────────────────────────────────────────────
# CLOUDFLARE DNS (AWS Route53 equivalent)
# ─────────────────────────────────────────────────────────────

# Create DNS record pointing to the LB
resource "cloudflare_record" "lb_dns" {
  count   = var.domain_root != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "gcp-dev" # gcp-dev.thisisblaze.uk
  type    = "A"
  content = module.global_lb.lb_ip_address
  proxied = false # Google manages SSL — no Cloudflare proxy allowed
  ttl     = 1
}

resource "cloudflare_record" "api_dns" {
  count   = var.domain_root != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "api-gcp-dev"
  type    = "A"
  content = module.global_lb.lb_ip_address
  proxied = false
  ttl     = 1
}
