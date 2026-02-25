# ──────────────────────────────────────────────────────────────────────────────
# multi-site-cdn — starter tfvars (lab / dev — wildcard cert path)
# ──────────────────────────────────────────────────────────────────────────────
# WILDCARD CERT SETUP (recommended for lab + agency subdomains):
#   All sites are *.yourdomain.com subdomains → 1 wildcard cert, zero SAN management
#   site_aliases = ["*.yourdomain.com"]
#   use_wildcard_cert = true
#   domain_root = "yourdomain.com"
#
# CUSTOM DOMAIN SETUP (for client-owned domains):
#   site_aliases = list of all custom domains (≤100 per SAN cert)
#   use_wildcard_cert = false
#   primary_domain = first domain in the list
#   ACM SAN cert auto-created with all aliases as SANs
#
# Price class:
#   PriceClass_100 = EU + US PoPs only — cheapest, best for EU-based sites
#   PriceClass_200 = adds Asia-Pacific
#   PriceClass_All = global (most expensive, only needed for global audience)
#
# Images S3 bucket:
#   If sites upload images to a shared S3 bucket, set images_s3_bucket_name
#   If sites serve images directly from their containers, leave empty ("")
#   Lambda@Edge will read from the S3 bucket as the origin for image URLs

use_wildcard_cert      = true
cloudfront_price_class = "PriceClass_100"
images_s3_bucket_name  = "" # Set to S3 bucket name if using S3 image origin
