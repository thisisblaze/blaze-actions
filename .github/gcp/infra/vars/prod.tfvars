# ─────────────────────────────────────────────────────────────
# GCP PROD Environment Variables
# ─────────────────────────────────────────────────────────────
# Production-grade: HA, deletion protection, higher capacity
# ─────────────────────────────────────────────────────────────

# ── Core ──
gcp_project_id = "blaze-b9-thisisblaze"
gcp_region     = "europe-west1"
namespace      = "blaze"
client_key     = "b9"
project_key    = "thisisblaze"
stage          = "prod"

# ── Network CIDRs (offset from dev & stage) ──
private_subnet_cidr = "10.2.0.0/20"
public_subnet_cidr  = "10.2.16.0/20"
pods_cidr           = "10.20.0.0/14"
services_cidr       = "10.24.0.0/20"

# ── Compute ──
api_min_instances      = 2 # HA: always 2 instances
api_max_instances      = 10
frontend_min_instances = 1 # Always-on frontend
frontend_max_instances = 10
api_cpu                = "2"
api_memory             = "1Gi"
frontend_cpu           = "1"
frontend_memory        = "512Mi"
use_vpc_connector      = true # Required for data layer
vpc_connector_cidr     = "10.10.0.0/28"

# ── Data ──
enable_redis                  = true
redis_tier                    = "STANDARD_HA" # HA with replication
redis_memory_size_gb          = 2
enable_cloud_sql              = true
cloud_sql_tier                = "db-custom-2-7680" # 2 vCPU, 7.5GB RAM
cloud_sql_ha                  = true               # REGIONAL HA
cloud_sql_disk_size           = 50
cloud_sql_deletion_protection = true # Prevent accidental deletion

# ── Storage ──
enable_storage = true

# ── Custom Domains ──
enable_custom_domains = true
domain_root           = "thisisblaze.uk"
