# ──────────────────────────────────────────────────────────────────────────────
# SITES DEFINITION — seed list (3 sites to validate the stack before full rollout)
# ──────────────────────────────────────────────────────────────────────────────
# HOW TO ADD A SITE:
#   1. Add an entry to this map with a unique slug key (lowercase, hyphens only)
#   2. Set tier = "standard" (EC2 ARM64, ~$8-10/mo) or "premium" (Fargate ARM64, instant scale)
#   3. Set domain to the fully-qualified public domain (CloudFront will terminate TLS)
#   4. Set container_image to the ECR URI (or public placeholder for initial deploy)
#   5. Run: terraform plan → review the diff → terraform apply
#
# QUOTA PRE-FLIGHT (MUST complete before first apply with >100 sites):
#   → Request AWS quota increase: Rules per ALB Listener: 100 → 250
#   → Request AWS quota increase: Target Groups per ALB: 100 → 200
#   → File at: AWS Console → EC2 → Load Balancers → Service Quotas
#
sites = {
  # ── STANDARD TIER — EC2 ARM64 Graviton, binpacked, ~$8-10/site/month ─────
  "site-001" = {
    domain            = "www.site001.example.com"
    tier              = "standard"
    container_image   = "public.ecr.aws/nginx/nginx:stable-arm64v8"
    health_check_path = "/health"
  }

  "site-002" = {
    domain            = "www.site002.example.com"
    tier              = "standard"
    container_image   = "public.ecr.aws/nginx/nginx:stable-arm64v8"
    health_check_path = "/health"
  }

  "site-003" = {
    domain            = "www.site003.example.com"
    tier              = "standard"
    container_image   = "public.ecr.aws/nginx/nginx:stable-arm64v8"
    health_check_path = "/health"
  }

  # ── PREMIUM TIER — Fargate ARM64, instant scale, CodeDeploy B/G ──────────
  # Uncomment and fill in real domain + ECR image when ready
  # "acme-main" = {
  #   domain          = "www.acmecorp.com"
  #   tier            = "premium"
  #   container_image = "123456789.dkr.ecr.eu-west-1.amazonaws.com/acme-main:latest"
  #   cpu             = 2048    # 2 vCPU (override for high-traffic site)
  #   memory          = 4096    # 4 GB
  #   min_capacity    = 2
  #   max_capacity    = 20
  # }
}
