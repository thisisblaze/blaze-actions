terraform {
  backend "s3" {}
  required_providers {
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
    random     = { source = "hashicorp/random", version = "~> 3.5" }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ---------------------------------------------------------
# CLOUDFLARE TUNNEL (DEV HOST ONLY)
# ---------------------------------------------------------
# ⚠️  IMPORTANT: This resource is for DEV **HOST** environment ONLY.
#     Feature Branches manage their own tunnels in dev-app/main.tf.
#     STAGE and PROD use Application Load Balancer (ALB) instead.
# ---------------------------------------------------------

resource "random_id" "tunnel_secret" {
  byte_length = 33
}

locals {
  # Build ingress rules list dynamically
  # For Host: API, Frontend, Kibana only (NO Admin)
  # Admin is served via Cloudflare Pages for Host
  tunnel_services = ["api", "frontend", "kibana"]

  ingress_rules = [
    for svc in local.tunnel_services : {
      hostname = "${svc}-${var.stage}.${var.domain_root}"
      service = "http://${svc}.${var.project_key}-${var.stage}.local:${
        svc == "api" ? "3001" : (svc == "frontend" ? "3000" : "5601")
      }"
      origin_request = svc != "kibana" ? {
        http_host_header = "${svc}.${var.project_key}-${var.stage}.local"
      } : null
    }
  ]
}

module "tunnel" {
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/tunnel?ref=v2.1.2"

  account_id = var.cloudflare_account_id
  name       = "${var.namespace}-${var.project_key}-${var.stage}-tunnel-${substr(random_id.tunnel_secret.hex, 0, 6)}"
  secret     = random_id.tunnel_secret.b64_std

  ingress_rules = local.ingress_rules
}

module "tunnel_dns" {
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/dns-record?ref=v2.1.2"

  zone_id = var.cloudflare_zone_id

  records = {
    for svc in local.tunnel_services : svc => {
      name    = "${svc}-${var.stage}"
      type    = "CNAME"
      content = module.tunnel.cname_target
      proxied = true
    }
  }
}

# ---------------------------------------------------------
# PAGES CUSTOM DOMAIN (DEV HOST ONLY)
# ---------------------------------------------------------
# Purpose: Bind the Admin Pages project to admin-dev.thisisblaze.uk
# ---------------------------------------------------------

module "admin_pages_project" {
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/pages-project?ref=v2.1.2"

  account_id   = var.cloudflare_account_id
  project_name = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage}-admin"

  # "main" is the default production branch. 
  # Deployment workflow updates this if needed, but we set a baseline here.
  production_branch = "main"
}


module "admin_pages_domain" {
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/pages-domain?ref=v2.1.2"

  account_id   = var.cloudflare_account_id
  project_name = module.admin_pages_project.name
  domain       = "admin-${var.stage}.${var.domain_root}"
}



# --------------------------------------------------------
# BASIC AUTH WORKER (FRONTEND ONLY)
# ---------------------------------------------------------
# Purpose: Protect frontend with HTTP Basic Auth
# API and Kibana remain public for development/testing
# ---------------------------------------------------------
module "basic_auth_worker" {
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/cloudflare/worker-basic-auth?ref=v2.1.2"

  account_id = var.cloudflare_account_id
  zone_id    = var.cloudflare_zone_id
  name       = "${var.namespace}-${var.project_key}-${var.stage}-basic-auth"

  credentials = var.basic_auth_credentials

  # Protect frontend only, API and Kibana remain public
  routes = ["frontend-${var.stage}.${var.domain_root}/*"]
}

# ---------------------------------------------------------
# OUTPUTS
# ---------------------------------------------------------
output "tunnel_token" {
  # Provider v5 bug: module output is empty. Construct manually.
  value = base64encode(jsonencode({
    a = var.cloudflare_account_id
    t = module.tunnel.tunnel_id
    s = random_id.tunnel_secret.b64_std
  }))
  sensitive = true
}

output "tunnel_id" {
  value = module.tunnel.tunnel_id
}

# ---------------------------------------------------------
# STATE MIGRATION: Cloudflare Provider v5
# ---------------------------------------------------------
# dns-record module renamed cloudflare_record → cloudflare_dns_record
# Per-instance moved blocks required for for_each resources
# moved blocks removed - see docs/reports/2026/01/AUDIT_REPORT_2026-01-26.md

