# ─────────────────────────────────────────────────────────────
# GCP DEV Environment Variables
# ─────────────────────────────────────────────────────────────
# Cost-optimized: scale-to-zero, basic tiers, no HA
# ─────────────────────────────────────────────────────────────

# ── Core ──
gcp_project_id = "blaze-b9-thisisblaze"
gcp_region     = "europe-west1"
namespace      = "blaze"
client_key     = "b9"
project_key    = "thisisblaze"
stage          = "dev"

# ── Network CIDRs ──
private_subnet_cidr = "10.0.0.0/20"
public_subnet_cidr  = "10.0.16.0/20"
pods_cidr           = "10.4.0.0/14"
services_cidr       = "10.8.0.0/20"

# ── Compute ──
api_min_instances      = 0 # Scale to zero
api_max_instances      = 3
frontend_min_instances = 0
frontend_max_instances = 3
api_cpu                = "1"
api_memory             = "512Mi"
frontend_cpu           = "1"
frontend_memory        = "256Mi"
use_vpc_connector      = false

# ── Data ──
enable_redis                  = true
redis_tier                    = "BASIC"
redis_memory_size_gb          = 1
enable_cloud_sql              = true
cloud_sql_tier                = "db-f1-micro"
cloud_sql_ha                  = false
cloud_sql_disk_size           = 10
cloud_sql_deletion_protection = false

# ── Storage ──
enable_storage = true

# ── DNS / Multi-Cloud ──
enable_custom_domains = true
