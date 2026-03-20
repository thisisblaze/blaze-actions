# ─────────────────────────────────────────────────────────────
# CDN + GLOBAL LOAD BALANCER (GCP STAGE)
# ─────────────────────────────────────────────────────────────
# Same as dev-cdn but with:
#   - WAF with OWASP rules enabled
#   - Managed SSL certificate
#   - HTTP→HTTPS redirect
#   - Longer CDN TTLs
# ─────────────────────────────────────────────────────────────

terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.15.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.15.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52.0"
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

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ── Remote State: App Stack ──
data "terraform_remote_state" "app" {
  backend = "gcs"
  config = {
    bucket = "${var.namespace}-${var.client_key}-tfstate"
    prefix = "infra/${var.project_key}/${var.stage}/app.tfstate"
  }
}

# ── Label ──
module "label" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/common/label?ref=v2.1.1"

  namespace  = var.namespace
  stage      = var.stage
  name       = "cdn"
  attributes = []
  tags       = {}
}

# ─────────────────────────────────────────────────────────────
# API ENABLEMENT
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
# CLOUD ARMOR (WAF) — OWASP rules enabled for stage
# ─────────────────────────────────────────────────────────────

module "cloud_armor" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/security/cloud-armor?ref=v2.1.1"

  context        = module.label.context
  gcp_project_id = var.gcp_project_id

  enable_owasp_rules               = true
  owasp_action                     = "deny(403)"
  enable_rate_limiting             = true
  rate_limit_requests_per_interval = 100
  rate_limit_interval_seconds      = 60
}

# ─────────────────────────────────────────────────────────────
# IMAGE RESIZE
# ─────────────────────────────────────────────────────────────

module "image_resize" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/compute/image-resize?ref=v2.1.1"

  context        = module.label.context
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  bucket_name        = "${var.namespace}-${var.client_key}-${var.stage}-image-resize"
  source_bucket_name = try(data.terraform_remote_state.app.outputs.storage_bucket_name, "")
  force_destroy      = false

  enable_cdn = false # Global LB handles CDN

  function_min_instances = 0
  function_max_instances = 10
}

# ─────────────────────────────────────────────────────────────
# GLOBAL HTTPS LB + CLOUD CDN
# ─────────────────────────────────────────────────────────────

module "global_lb" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/gcp/cdn/global-https-lb?ref=v2.1.1"

  context        = module.label.context
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  backend_services = [
    {
      name            = "api"
      type            = "cloud_run"
      service_name    = try(data.terraform_remote_state.app.outputs.api_service_name, "blaze-api")
      enable_cdn      = false
      timeout_sec     = 60
      security_policy = module.cloud_armor.policy_self_link
    },
    {
      name            = "frontend"
      type            = "cloud_run"
      service_name    = try(data.terraform_remote_state.app.outputs.frontend_service_name, "blaze-frontend")
      enable_cdn      = true
      cdn_cache_mode  = "USE_ORIGIN_HEADERS"
      cdn_default_ttl = 7200   # 2 hours
      cdn_max_ttl     = 604800 # 7 days
      security_policy = module.cloud_armor.policy_self_link
    },
    {
      name                     = "image-resize"
      type                     = "cloud_function"
      service_name             = module.image_resize.function_name
      enable_cdn               = true
      cdn_cache_mode           = "USE_ORIGIN_HEADERS"
      cdn_default_ttl          = 86400
      cdn_max_ttl              = 31536000
      cdn_include_query_string = true
      security_policy          = module.cloud_armor.policy_self_link
    }
  ]

  default_backend = "frontend"

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

  # Stage: SSL enabled
  managed_ssl_domains  = var.managed_ssl_domains
  enable_http_redirect = true

  enable_logging  = true
  log_sample_rate = 0.5
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
  description = "Direct URL for image resize function"
  value       = module.image_resize.function_url
}

output "cloud_armor_policy" {
  description = "Cloud Armor WAF policy self_link"
  value       = module.cloud_armor.policy_self_link
}

# ─────────────────────────────────────────────────────────────
# CLOUDFLARE DNS — Point domain to GCP Global LB
# ─────────────────────────────────────────────────────────────
# Same pattern as Azure Front Door: DNS record managed alongside
# the LB/CDN stack. proxied = false because GCP manages SSL
# via Google-managed certificates (not Cloudflare).
# ─────────────────────────────────────────────────────────────

resource "cloudflare_dns_record" "lb_dns" {
  count   = var.domain_root != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "gcp-stage" # gcp-stage.thisisblaze.uk → GCP Global LB
  type    = "A"
  content = module.global_lb.lb_ip_address
  proxied = false # GCP manages SSL — no Cloudflare proxy
  ttl     = 1     # Auto
}

resource "cloudflare_dns_record" "api_dns" {
  count   = var.domain_root != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "api-gcp-stage"
  type    = "A"
  content = module.global_lb.lb_ip_address
  proxied = false
  ttl     = 1
}
