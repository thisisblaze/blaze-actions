#!/bin/bash
# Import existing STAGE network resources into Terraform state
# Run this before terraform apply if resources already exist

set -e

echo "🔍 Importing existing STAGE network resources..."

# S3 ALB Logs Bucket
if ! terraform state list | grep -q "module.environment_network.module.access_logs_bucket\\[0\\].aws_s3_bucket.this"; then
  echo "📥 Importing S3 ALB logs bucket..."
  terraform import 'module.environment_network.module.access_logs_bucket[0].aws_s3_bucket.this' blaze-b9-thisisblaze-stage-alb-logs || true
fi

# S3 Log Bucket (top-level module in stage-network/main.tf)
if ! terraform state list | grep -q "module.log_bucket.aws_s3_bucket.this"; then
  if aws s3api head-bucket --bucket blaze-b9-thisisblaze-stage-logs --region "$REGION" 2>/dev/null; then
    echo "📥 Importing S3 log bucket..."
    terraform import 'module.log_bucket.aws_s3_bucket.this[0]' blaze-b9-thisisblaze-stage-logs || true
  fi
fi

# Target Groups
# Uses AWS_REGION or defaults to eu-west-1
REGION="${AWS_REGION:-eu-west-1}"
STAGE="${TF_VAR_stage:-stage}"

for TG in admin-blue admin-green frontend-blue frontend-green api-blue api-green; do
  RESOURCE_NAME=$(echo "$TG" | tr '-' '_')
  TG_ARN=$(aws elbv2 describe-target-groups --names "blaze-stage-${TG}-tg" --region "$REGION" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
  
  if [[ -n "$TG_ARN" && "$TG_ARN" != "None" ]]; then
    if ! terraform state list | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}"; then
      echo "📥 Importing target group: blaze-stage-${TG}-tg"
      terraform import "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}[0]" "$TG_ARN" || true
    fi
  fi
done

# CloudFront Cache Policies (orphaned when state was wiped but CF distribution existed)
for POLICY_NAME in "image-resize:module.environment_network.aws_cloudfront_cache_policy.image_resize[0]" \
                   "cdn-default:module.environment_network.aws_cloudfront_cache_policy.cdn_default[0]"; do
  PNAME="${POLICY_NAME%%:*}"
  RESOURCE="${POLICY_NAME##*:}"
  FULL_POLICY_NAME="blaze-b9-thisisblaze-stage-ecs-${PNAME}"
  POLICY_ID=$(aws cloudfront list-cache-policies --type custom --region "$REGION" \
    --query "CachePolicyList.Items[?CachePolicy.CachePolicyConfig.Name=='${FULL_POLICY_NAME}'].CachePolicy.Id" \
    --output text 2>/dev/null || echo "")
  if [[ -n "$POLICY_ID" && "$POLICY_ID" != "None" ]]; then
    if ! terraform state list | grep -qF "$RESOURCE"; then
      echo "📥 Importing CF cache policy: ${FULL_POLICY_NAME} (${POLICY_ID})"
      terraform import "$RESOURCE" "$POLICY_ID" || true
    fi
  fi
done

# Security Group: ALB SG
SG_ID=$(aws ec2 describe-security-groups --region "$REGION" \
  --filters "Name=group-name,Values=blaze-b9-thisisblaze-stage-alb-sg" \
  --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
if [[ -n "$SG_ID" && "$SG_ID" != "None" ]]; then
  if ! terraform state list | grep -q "module.environment_network.module.alb_sg\|module.environment_network.aws_security_group.alb"; then
    echo "📥 Importing ALB security group: ${SG_ID}"
    terraform import 'module.environment_network.module.lb[0].module.sg.aws_security_group.this[0]' "$SG_ID" || true
  fi
fi

# S3 Image-Resize Bucket
if ! terraform state list | grep -q "module.environment_network.module.image_resize_bucket\[0\].aws_s3_bucket.this"; then
  if aws s3api head-bucket --bucket blaze-b9-thisisblaze-stage-ecs-image-resize --region "$REGION" 2>/dev/null; then
    echo "📥 Importing S3 image-resize bucket..."
    terraform import 'module.environment_network.module.image_resize_bucket[0].aws_s3_bucket.this' blaze-b9-thisisblaze-stage-ecs-image-resize || true
  fi
fi

# WAF WebACL (CloudFront scope — ALWAYS us-east-1)
WAF_ID=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 \
  --query "WebACLs[?Name=='blaze-b9-thisisblaze-stage-cloudfront'].Id" --output text 2>/dev/null || echo "")
WAF_NAME="blaze-b9-thisisblaze-stage-cloudfront"
if [[ -n "$WAF_ID" && "$WAF_ID" != "None" ]]; then
  if ! terraform state list | grep -q "module.environment_network.module.waf_global\[0\].aws_wafv2_web_acl.this"; then
    echo "📥 Importing WAF WebACL: ${WAF_NAME} (${WAF_ID})"
    # Terraform aws_wafv2_web_acl import format: id/name/scope
    terraform import 'module.environment_network.module.waf_global[0].aws_wafv2_web_acl.this[0]' "${WAF_ID}/${WAF_NAME}/CLOUDFRONT" || true
  fi
fi

# Cloudflare DNS Records (Cloudflare provider v5 — resource name: cloudflare_dns_record)
echo "📥 Checking Cloudflare DNS Records..."
CF_TOKEN="${TF_VAR_cloudflare_api_token:-$CLOUDFLARE_API_TOKEN}"
CF_ZONE="${TF_VAR_cloudflare_zone_id:-$CLOUDFLARE_ZONE_ID}"
DOMAIN_ROOT="${domain_root:-thisisblaze.uk}" # fallback

if [[ -n "$CF_TOKEN" && -n "$CF_ZONE" ]]; then
  # Standard A/CNAME records: admin, frontend, api, api_direct, cdn
  for TYPE in admin frontend api api_direct cdn; do
    # Determine Record Name
    if [[ "$TYPE" == "frontend" && "$STAGE" == "stage" ]]; then
       # stage-network uses frontend_subdomain_override="frontend-stage"
       # The actual Cloudflare DNS record name is frontend-stage.thisisblaze.uk
       RECORD_NAME="frontend-${STAGE}.${DOMAIN_ROOT}"

    elif [[ "$TYPE" == "api" && "$STAGE" == "stage" ]]; then
       RECORD_NAME="api-${STAGE}.${DOMAIN_ROOT}"
    elif [[ "$TYPE" == "api_direct" ]]; then
       RECORD_NAME="api-direct-${STAGE}.${DOMAIN_ROOT}"
    elif [[ "$TYPE" == "cdn" ]]; then
       RECORD_NAME="cdn-${STAGE}.${DOMAIN_ROOT}"
    else
       RECORD_NAME="${TYPE}-${STAGE}.${DOMAIN_ROOT}"
    fi

    # Check if record exists in Cloudflare
    REC_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/dns_records?name=$RECORD_NAME" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

    # v5 resource name: cloudflare_dns_record (not cloudflare_record)
    if [[ -n "$REC_ID" ]]; then
       RESOURCE="module.environment_network.cloudflare_dns_record.${TYPE}[0]"
       if ! terraform state list | grep -qF "$RESOURCE"; then
         echo "📥 Importing Cloudflare Record: $RECORD_NAME ($REC_ID)..."
         terraform import "$RESOURCE" "${CF_ZONE}/${REC_ID}" || true
       else
         echo "   $RECORD_NAME already in state."
       fi
    else
       echo "   $RECORD_NAME not found in Cloudflare (Safe to create)."
    fi
  done

  # ACM Validation CNAME record (name is dynamic: _xxx.domain_root)
  # Look up by searching for CNAME records starting with '_' for this domain
  VALIDATION_RESOURCE="module.environment_network.cloudflare_dns_record.validation[\"${DOMAIN_ROOT}\"]"
  if ! terraform state list | grep -qF "cloudflare_dns_record.validation"; then
    echo "📥 Looking up ACM validation CNAME for ${DOMAIN_ROOT}..."
    # Search all CNAME records containing the domain root with name starting with _
    VALIDATION_REC=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/dns_records?type=CNAME&per_page=50" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json" | jq -r '.result[] | select(.name | startswith("_")) | select(.name | endswith("'"${DOMAIN_ROOT}"'")) | .id' | head -1)
    if [[ -n "$VALIDATION_REC" ]]; then
      echo "📥 Importing ACM validation record ($VALIDATION_REC)..."
      terraform import "$VALIDATION_RESOURCE" "${CF_ZONE}/${VALIDATION_REC}" || true
    else
      echo "   No ACM validation CNAME found (will be created)."
    fi
  else
    echo "   ACM validation record already in state."
  fi
else
  echo "⚠️ Missing Cloudflare Credentials. Skipping DNS Import."
fi

echo "✅ Import complete. You can now run terraform apply safely."
