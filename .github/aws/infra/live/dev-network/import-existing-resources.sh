#!/bin/bash
# Import existing DEV network resources into Terraform state
# Run this before terraform apply if resources already exist in AWS/Cloudflare
# Safe to run on greenfield — all imports are guarded by existence checks

# NOTE: No 'set -e'. All 'terraform import' calls use '|| true' so a missing
# resource on a fresh stack is harmless. The pre-apply script continues regardless.

REGION="${AWS_REGION:-eu-west-1}"
STAGE="dev"
NAMESPACE="${TF_VAR_namespace:-blaze}"
CLIENT="${TF_VAR_client_key:-b9}"
PROJECT="${TF_VAR_project_key:-thisisblaze}"
PREFIX="${NAMESPACE}-${CLIENT}-${PROJECT}-${STAGE}"

echo "🔍 Importing existing DEV network resources (prefix: ${PREFIX})..."

# ─── S3: ALB Access Logs Bucket ───────────────────────────────────────────────
ALB_LOGS_BUCKET="${PREFIX}-alb-logs"
if ! terraform state list 2>/dev/null | grep -q "module.environment_network.module.access_logs_bucket\[0\].aws_s3_bucket.this"; then
  if aws s3api head-bucket --bucket "${ALB_LOGS_BUCKET}" --region "${REGION}" 2>/dev/null; then
    echo "📥 Importing S3 ALB logs bucket: ${ALB_LOGS_BUCKET}"
    terraform import 'module.environment_network.module.access_logs_bucket[0].aws_s3_bucket.this' "${ALB_LOGS_BUCKET}" || true
  else
    echo "   ⏭️  ALB logs bucket not found — will be created."
  fi
fi

# ─── S3: General Log Bucket ───────────────────────────────────────────────────
LOG_BUCKET="${PREFIX}-logs"
if ! terraform state list 2>/dev/null | grep -q "module.log_bucket.aws_s3_bucket.this"; then
  if aws s3api head-bucket --bucket "${LOG_BUCKET}" --region "${REGION}" 2>/dev/null; then
    echo "📥 Importing S3 log bucket: ${LOG_BUCKET}"
    terraform import 'module.log_bucket.aws_s3_bucket.this[0]' "${LOG_BUCKET}" || true
  else
    echo "   ⏭️  Log bucket not found — will be created."
  fi
fi

# ─── S3: Image-Resize Bucket ──────────────────────────────────────────────────
IMG_BUCKET="${PREFIX}-ecs-image-resize"
if ! terraform state list 2>/dev/null | grep -q "module.environment_network.module.image_resize_bucket\[0\].aws_s3_bucket.this"; then
  if aws s3api head-bucket --bucket "${IMG_BUCKET}" --region "${REGION}" 2>/dev/null; then
    echo "📥 Importing S3 image-resize bucket: ${IMG_BUCKET}"
    terraform import 'module.environment_network.module.image_resize_bucket[0].aws_s3_bucket.this' "${IMG_BUCKET}" || true
  else
    echo "   ⏭️  Image-resize bucket not found — will be created."
  fi
fi

# ─── ALB Target Groups (B/G) ──────────────────────────────────────────────────
for TG in admin-blue admin-green frontend-blue frontend-green api-blue api-green; do
  RESOURCE_NAME=$(echo "${TG}" | tr '-' '_')
  TG_NAME="${NAMESPACE}-${STAGE}-${TG}-tg"
  TG_ARN=$(aws elbv2 describe-target-groups --names "${TG_NAME}" --region "${REGION}" \
    --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")

  if [[ -n "${TG_ARN}" && "${TG_ARN}" != "None" ]]; then
    if ! terraform state list 2>/dev/null | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}"; then
      echo "📥 Importing target group: ${TG_NAME}"
      terraform import "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}[0]" "${TG_ARN}" || true
    else
      echo "   ${TG_NAME} already in state."
    fi
  else
    echo "   ⏭️  Target group ${TG_NAME} not found — will be created."
  fi
done

# ─── CloudFront Cache Policies ─────────────────────────────────────────────────
for POLICY_NAME in "image-resize:module.environment_network.aws_cloudfront_cache_policy.image_resize[0]" \
                   "cdn-default:module.environment_network.aws_cloudfront_cache_policy.cdn_default[0]"; do
  PNAME="${POLICY_NAME%%:*}"
  RESOURCE="${POLICY_NAME##*:}"
  FULL_POLICY_NAME="${PREFIX}-ecs-${PNAME}"
  POLICY_ID=$(aws cloudfront list-cache-policies --type custom --region "${REGION}" \
    --query "CachePolicyList.Items[?CachePolicy.CachePolicyConfig.Name=='${FULL_POLICY_NAME}'].CachePolicy.Id" \
    --output text 2>/dev/null || echo "")
  if [[ -n "${POLICY_ID}" && "${POLICY_ID}" != "None" ]]; then
    if ! terraform state list 2>/dev/null | grep -qF "${RESOURCE}"; then
      echo "📥 Importing CF cache policy: ${FULL_POLICY_NAME} (${POLICY_ID})"
      terraform import "${RESOURCE}" "${POLICY_ID}" || true
    else
      echo "   CF cache policy ${FULL_POLICY_NAME} already in state."
    fi
  else
    echo "   ⏭️  CF cache policy ${FULL_POLICY_NAME} not found — will be created."
  fi
done

# ─── Security Group: ALB SG ───────────────────────────────────────────────────
ALB_SG_NAME="${PREFIX}-alb-sg"
SG_ID=$(aws ec2 describe-security-groups --region "${REGION}" \
  --filters "Name=group-name,Values=${ALB_SG_NAME}" \
  --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
if [[ -n "${SG_ID}" && "${SG_ID}" != "None" ]]; then
  if ! terraform state list 2>/dev/null | grep -q "module.environment_network.module.alb_sg\|module.environment_network.aws_security_group.alb"; then
    echo "📥 Importing ALB security group: ${SG_ID}"
    terraform import 'module.environment_network.module.lb[0].module.sg.aws_security_group.this[0]' "${SG_ID}" || true
  else
    echo "   ALB SG already in state."
  fi
else
  echo "   ⏭️  ALB SG ${ALB_SG_NAME} not found — will be created."
fi

# ─── WAF WebACL (CloudFront scope — must query us-east-1) ─────────────────────
WAF_NAME="${NAMESPACE}-${CLIENT}-${PROJECT}-${STAGE}-cloudfront"
WAF_ID=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 \
  --query "WebACLs[?Name=='${WAF_NAME}'].Id" --output text 2>/dev/null || echo "")
if [[ -n "${WAF_ID}" && "${WAF_ID}" != "None" ]]; then
  if ! terraform state list 2>/dev/null | grep -q "module.environment_network.module.waf_global\[0\].aws_wafv2_web_acl.this"; then
    echo "📥 Importing WAF WebACL: ${WAF_NAME} (${WAF_ID})"
    terraform import 'module.environment_network.module.waf_global[0].aws_wafv2_web_acl.this[0]' "${WAF_ID}/${WAF_NAME}/CLOUDFRONT" || true
  else
    echo "   WAF ${WAF_NAME} already in state."
  fi
else
  echo "   ⏭️  WAF ${WAF_NAME} not found — will be created."
fi

# ─── Cloudflare DNS Records ───────────────────────────────────────────────────
echo "📥 Checking Cloudflare DNS Records..."
CF_TOKEN="${TF_VAR_cloudflare_api_token:-$CLOUDFLARE_API_TOKEN}"
CF_ZONE="${TF_VAR_cloudflare_zone_id:-$CLOUDFLARE_ZONE_ID}"
DOMAIN_ROOT="${TF_VAR_domain_root:-thisisblaze.uk}"

if [[ -n "${CF_TOKEN}" && -n "${CF_ZONE}" ]]; then
  # dev-network uses frontend_subdomain_override="frontend-dev"
  declare -A CF_RECORD_MAP
  CF_RECORD_MAP["admin"]="admin-${STAGE}.${DOMAIN_ROOT}"
  CF_RECORD_MAP["frontend"]="frontend-${STAGE}.${DOMAIN_ROOT}"
  CF_RECORD_MAP["api"]="api-${STAGE}.${DOMAIN_ROOT}"
  CF_RECORD_MAP["api_direct"]="api-direct-${STAGE}.${DOMAIN_ROOT}"
  CF_RECORD_MAP["cdn"]="cdn-${STAGE}.${DOMAIN_ROOT}"

  for TYPE in admin frontend api api_direct cdn; do
    RECORD_NAME="${CF_RECORD_MAP[$TYPE]}"
    REC_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records?name=${RECORD_NAME}" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

    if [[ -n "${REC_ID}" ]]; then
      RESOURCE="module.environment_network.cloudflare_dns_record.${TYPE}[0]"
      if ! terraform state list 2>/dev/null | grep -qF "${RESOURCE}"; then
        echo "📥 Importing Cloudflare Record: ${RECORD_NAME} (${REC_ID})"
        terraform import "${RESOURCE}" "${CF_ZONE}/${REC_ID}" || true
      else
        echo "   ${RECORD_NAME} already in state."
      fi
    else
      echo "   ⏭️  ${RECORD_NAME} not in Cloudflare — will be created."
    fi
  done

  # ACM Validation CNAME
  VALIDATION_RESOURCE="module.environment_network.cloudflare_dns_record.validation[\"${DOMAIN_ROOT}\"]"
  if ! terraform state list 2>/dev/null | grep -qF "cloudflare_dns_record.validation"; then
    echo "📥 Looking up ACM validation CNAME for ${DOMAIN_ROOT}..."
    VALIDATION_REC=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records?type=CNAME&per_page=50" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" | \
      jq -r ".result[] | select(.name | startswith(\"_\")) | select(.name | endswith(\"${DOMAIN_ROOT}\")) | .id" | head -1)
    if [[ -n "${VALIDATION_REC}" ]]; then
      echo "📥 Importing ACM validation record (${VALIDATION_REC})"
      terraform import "${VALIDATION_RESOURCE}" "${CF_ZONE}/${VALIDATION_REC}" || true
    else
      echo "   ⏭️  No ACM validation CNAME found — will be created."
    fi
  else
    echo "   ACM validation record already in state."
  fi
else
  echo "⚠️  Missing Cloudflare credentials — skipping DNS import."
fi

echo "✅ DEV import complete. Ready for terraform plan/apply."
