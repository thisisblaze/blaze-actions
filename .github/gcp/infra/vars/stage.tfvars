# ─────────────────────────────────────────────────────────────
# GCP STAGE Environment Variables
# ─────────────────────────────────────────────────────────────
# Warm & resilient: always-on API, backups enabled, VPC connector
# ─────────────────────────────────────────────────────────────

# ── Core ──
gcp_project_id = "blaze-b9-thisisblaze"
gcp_region     = "europe-west1"
namespace      = "blaze"
client_key     = "b9"
project_key    = "thisisblaze"
stage          = "stage"

# ── Network CIDRs (offset from dev) ──
private_subnet_cidr = "10.1.0.0/20"
public_subnet_cidr  = "10.1.16.0/20"
pods_cidr           = "10.12.0.0/14"
services_cidr       = "10.16.0.0/20"

# ── Compute ──
api_min_instances      = 1 # Always warm (no cold starts)
api_max_instances      = 5
frontend_min_instances = 0
frontend_max_instances = 5
api_cpu                = "1"
api_memory             = "512Mi"
frontend_cpu           = "1"
frontend_memory        = "256Mi"
use_vpc_connector      = true # Enable for data layer access
vpc_connector_cidr     = "10.9.0.0/28"

# ── Data ──
enable_redis                  = true
redis_tier                    = "BASIC"
redis_memory_size_gb          = 1
enable_cloud_sql              = true
cloud_sql_tier                = "db-g1-small"
cloud_sql_ha                  = false # ZONAL for stage
cloud_sql_disk_size           = 20
cloud_sql_deletion_protection = false

# ── Storage ──
enable_storage = true

# ── Custom Domains ──
enable_custom_domains = true
domain_root           = "thisisblaze.uk"
