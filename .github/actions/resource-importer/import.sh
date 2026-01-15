#!/bin/bash
set -e

# Inputs (Environment Variables)
STACK="${INPUT_STACK:-$1}"
DOMAIN="${INPUT_DOMAIN_ROOT:-$2}"
REGION="${INPUT_AWS_REGION:-$3}"

echo "🔍 Running Smart Import Logic for Stack: $STACK"

if [[ "$STACK" == "acm" ]]; then
  echo "   Checking for existing Regional cert for $DOMAIN in $REGION..."
  
  # 1. Regional Cert
  if ! terraform state list | grep -q "aws_acm_certificate.main"; then
     ARN=$(aws acm list-certificates --region "$REGION" --query "CertificateSummaryList[?DomainName=='$DOMAIN' || DomainName=='*.$DOMAIN'].CertificateArn" --output text | head -1)
     if [[ -n "$ARN" && "$ARN" != "None" ]]; then
        echo "   📥 Importing Regional Cert: $ARN"
        export TF_VAR_domain_root="$DOMAIN"
        terraform import aws_acm_certificate.main "$ARN" || echo "   ⚠️ Import failed (or already imported)"
     fi
  fi
  
  # 2. CloudFront Cert (us-east-1)
  if ! terraform state list | grep -q "aws_acm_certificate.cloudfront"; then
     echo "   Checking for existing CloudFront cert for $DOMAIN in us-east-1..."
     ARN=$(aws acm list-certificates --region "us-east-1" --query "CertificateSummaryList[?DomainName=='$DOMAIN' || DomainName=='*.$DOMAIN'].CertificateArn" --output text | head -1)
     if [[ -n "$ARN" && "$ARN" != "None" ]]; then
        echo "   📥 Importing CloudFront Cert: $ARN"
        export TF_VAR_domain_root="$DOMAIN"
        terraform import aws_acm_certificate.cloudfront "$ARN" || echo "   ⚠️ Import failed"
     fi
  fi

elif [[ "$STACK" == "third-party-mongodb" ]]; then
  echo "🔍 Running MongoDB Smart Import Logic..."
  # Required Env Vars: MONGODB_ATLAS_PROJECT_ID, MONGODB_ATLAS_PUBLIC_KEY, MONGODB_ATLAS_PRIVATE_KEY
  # Plus context variables passed from workflow
  
  CLUSTER_NAME="${INPUT_CLUSTER_NAME}"
  
  if [[ -z "$CLUSTER_NAME" ]]; then
     echo "❌ ERROR: INPUT_CLUSTER_NAME not provided. Cannot import MongoDB cluster."
     echo "   Ensure calculate-config outputs a valid cluster_name."
     exit 1
  fi

  PROJECT_ID="$MONGODB_ATLAS_PROJECT_ID"
  
  if [[ -z "$PROJECT_ID" ]]; then
      echo "⚠️ MONGODB_ATLAS_PROJECT_ID is not set. Skipping import."
      exit 0
  fi

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --digest -u "$MONGODB_ATLAS_PUBLIC_KEY:$MONGODB_ATLAS_PRIVATE_KEY" \
    "https://cloud.mongodb.com/api/atlas/v1.0/groups/$PROJECT_ID/clusters/$CLUSTER_NAME")
    
  if [[ "$HTTP_CODE" == "200" ]]; then
    echo "✅ Cluster $CLUSTER_NAME found in Atlas. Importing..."
    if ! terraform state list | grep -q "mongodbatlas_cluster.main"; then
      terraform import mongodbatlas_cluster.main "$PROJECT_ID-$CLUSTER_NAME" || echo "⚠️ Import failed"
    fi
  else
    echo "ℹ️ Cluster $CLUSTER_NAME not found (HTTP $HTTP_CODE). Terraform will create it."
  fi

elif [[ "$STACK" == "third-party-elastic" ]]; then
  echo "🔍 Running Elastic Smart Import Logic..."
  # Required Env Vars: EC_API_KEY
  
  # Elastic deployments often follow specific naming.
  # We rely on INPUT_CLUSTER_NAME passed from the workflow.
  
  DEPLOYMENT_NAME="${INPUT_CLUSTER_NAME}"
  
  if [[ -z "$DEPLOYMENT_NAME" ]]; then
      echo "❌ ERROR: INPUT_CLUSTER_NAME not provided. Cannot import Elastic deployment."
      exit 1
  fi
  
  if [[ -z "$EC_API_KEY" ]]; then
      echo "⚠️ EC_API_KEY is not set. Skipping import."
      exit 0
  fi
  
  SEARCH_PAYLOAD="{\"query\": {\"match\": {\"name\": \"$DEPLOYMENT_NAME\"}}}"
  RESPONSE=$(curl -s -X POST "https://api.elastic-cloud.com/api/v1/deployments/search" \
    -H "Authorization: ApiKey $EC_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$SEARCH_PAYLOAD")
    
  DEPLOYMENT_ID=$(echo "$RESPONSE" | jq -r '.deployments[0].id // empty')
  
  if [[ -n "$DEPLOYMENT_ID" ]]; then
    echo "✅ Deployment found: $DEPLOYMENT_ID. Importing..."
    if ! terraform state list | grep -q "ec_deployment.main"; then
      terraform import ec_deployment.main "$DEPLOYMENT_ID" || echo "⚠️ Import failed"
    fi
  else
    echo "ℹ️ Deployment $DEPLOYMENT_NAME not found. Terraform will create it."
  fi

elif [[ "$STACK" == "network" ]]; then
  echo "🔍 Running Network Smart Import & Cleanup Logic..."
  
  CLIENT_KEY="${INPUT_CLIENT_KEY}"
  PROJECT_KEY="${INPUT_PROJECT_KEY}"
  STAGE_KEY="${INPUT_STAGE_KEY}"
  
  # Import existing S3 ALB Logs Bucket
  S3_ALB_LOGS="blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-alb-logs"
  if aws s3api head-bucket --bucket "$S3_ALB_LOGS" 2>/dev/null; then
    if ! terraform state list | grep -q "module.environment_network.module.access_logs_bucket\[0\].aws_s3_bucket.this"; then
      echo "📥 Importing S3 ALB logs bucket: $S3_ALB_LOGS"
      terraform import 'module.environment_network.module.access_logs_bucket[0].aws_s3_bucket.this' "$S3_ALB_LOGS" || true
    fi
  fi
  
  # Import WAF Web ACL (CloudFront scope in us-east-1)
  WAF_NAME="blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-cloudfront"
  WAF_ID=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 --query "WebACLs[?Name=='$WAF_NAME'].Id" --output text 2>/dev/null || echo "")
  if [[ -n "$WAF_ID" && "$WAF_ID" != "None" ]]; then
    if ! terraform state list | grep -q "module.environment_network.module.waf_global\[0\].aws_wafv2_web_acl.this"; then
      echo "📥 Importing WAF Web ACL: $WAF_NAME"
      ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
      WAF_ARN="arn:aws:wafv2:us-east-1:${ACCOUNT_ID}:global/webacl/${WAF_NAME}/${WAF_ID}"
      terraform import 'module.environment_network.module.waf_global[0].aws_wafv2_web_acl.this[0]' "${WAF_ARN}/${WAF_NAME}/${WAF_ID}" || true
    fi
  fi
  
  # Import Target Groups (Blue/Green for Admin, Frontend, API)
  for TG in admin-blue admin-green frontend-blue frontend-green api-blue api-green; do
    RESOURCE_NAME=$(echo "$TG" | tr '-' '_')
    TG_NAME="blaze-${STAGE_KEY}-${TG}-tg"
    TG_ARN=$(aws elbv2 describe-target-groups --names "$TG_NAME" --region "$REGION" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
    
    if [[ -n "$TG_ARN" && "$TG_ARN" != "None" ]]; then
      if ! terraform state list | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}"; then
        echo "📥 Importing target group: $TG_NAME"
        terraform import "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}[0]" "$TG_ARN" || true
      fi
    fi
  done
  
  # Cloudflare ACM Validation Cleanup
  if [[ -n "$TF_VAR_cloudflare_api_token" && -n "$TF_VAR_cloudflare_zone_id" ]]; then
    echo "   🧹 Checking for clashing validation records in Cloudflare..."
    
    # Validation records typically start with _
    # We look for ANY CNAME records in the zone that might be validation records
    RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$TF_VAR_cloudflare_zone_id/dns_records?type=CNAME" \
      -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
      -H "Content-Type: application/json")
    
    # Find records that look like ACM validation (starting with _)
    BAD_IDS=$(echo "$RECORDS" | jq -r '.result[] | select(.name | startswith("_")) | .id')
    
    for ID in $BAD_IDS; do
      NAME=$(echo "$RECORDS" | jq -r ".result[] | select(.id==\"$ID\") | .name")
      echo "   🗑️ Deleting conflicting record: $NAME ($ID)"
      curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$TF_VAR_cloudflare_zone_id/dns_records/$ID" \
        -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
        -H "Content-Type: application/json" > /dev/null
    done
  else
    echo "   ⚠️ Cloudflare credentials missing. Skipping cleanup."
  fi

else
  echo "ℹ️ No smart import logic defined for stack: $STACK"
fi
