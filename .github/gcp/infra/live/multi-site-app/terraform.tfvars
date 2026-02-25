# ─────────────────────────────────────────────────────────────
# MULTI-SITE FLEET CONFIGURATION (GCP)
# ─────────────────────────────────────────────────────────────

gcp_project_id = "your-gcp-project"
gcp_region     = "europe-west1"

# ─────────────────────────────────────────────────────────────
# THE 120 WEBSITES MAP
# Start with some sample sites for initial testing.
# ─────────────────────────────────────────────────────────────

sites = {
  "acme-standard" = {
    domain        = "www.acme-standard.com"
    cpu           = "1"
    memory        = "512Mi"
    min_instances = 0
    cpu_idle      = true
    enable_cdn    = true
  }
}
