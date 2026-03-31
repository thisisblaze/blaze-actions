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

elif [[ "$STACK" == "network" || "$STACK" == "multi-site-network" ]]; then
  echo "🔍 Running Network Smart Import & Cleanup Logic..."
  
  CLIENT_KEY="${INPUT_CLIENT_KEY}"
  PROJECT_KEY="${INPUT_PROJECT_KEY}"
  STAGE_KEY="${INPUT_STAGE_KEY}"
  
  # Import existing S3 ALB Logs Bucket
  S3_ALB_LOGS="blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-alb-logs"
  if aws s3api head-bucket --bucket "$S3_ALB_LOGS" 2>/dev/null; then
    if ! terraform state list | grep -q "module.environment_network.module.access_logs_bucket\[0\].aws_s3_bucket.this\[0\]"; then
      echo "📥 Importing S3 ALB logs bucket: $S3_ALB_LOGS"
      terraform import 'module.environment_network.module.access_logs_bucket[0].aws_s3_bucket.this[0]' "$S3_ALB_LOGS" || true
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
  # Note: frontend is abbreviated as 'fe' in target group names
  # Strategy: try to import first; if import fails (e.g. config count=0 or address mismatch),
  # delete the orphan from AWS so terraform apply can recreate it cleanly.
  for TG in admin-blue admin-green fe-blue fe-green api-blue api-green; do
    RESOURCE_NAME=$(echo "$TG" | sed 's/fe-/frontend_/' | tr '-' '_')
    TG_NAME="blaze-${STAGE_KEY}-${TG}-tg"
    TG_ARN=$(aws elbv2 describe-target-groups --names "$TG_NAME" --region "$REGION" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")

    if [[ -n "$TG_ARN" && "$TG_ARN" != "None" ]]; then
      if ! terraform state list | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}"; then
        echo "📥 Importing target group: $TG_NAME"
        terraform import "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}[0]" "$TG_ARN" 2>/dev/null || true
        # If still not in state after import attempt, delete the orphan so apply can recreate it
        if ! terraform state list | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}"; then
          echo "   ⚠️  Import failed — deleting orphan TG from AWS: $TG_NAME"
          aws elbv2 delete-target-group --target-group-arn "$TG_ARN" --region "$REGION" && \
            echo "   ✅ Deleted orphan TG: $TG_NAME" || \
            echo "   ⚠️  Could not delete $TG_NAME (may have active dependencies)"
        fi
      fi
    fi
  done
  
  # Cloudflare ACM Validation — Import into state instead of deleting
  # Background: ACM validation CNAMEs are long-lived records. Deleting them
  # causes ACM to regenerate them mid-apply, creating duplicate conflicts.
  # Correct fix: import any existing validation records into Terraform state
  # so Terraform treats them as managed (no-op) rather than trying to create.
  if [[ -n "$TF_VAR_cloudflare_api_token" && -n "$TF_VAR_cloudflare_zone_id" ]]; then
    echo "   🔵 Checking Cloudflare ACM validation records to import into state..."
    DOMAIN_ROOT="${TF_VAR_domain:-}"
    if [[ -z "$DOMAIN_ROOT" ]]; then
      DOMAIN_ROOT=$(terraform output -raw domain_root 2>/dev/null || echo "")
    fi

    if [[ -n "$DOMAIN_ROOT" ]]; then
      CF_ZONE="$TF_VAR_cloudflare_zone_id"
      # Look for the ACM validation CNAME (starts with _ under the domain)
      VALIDATION_RECORDS=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records?type=CNAME" \
        -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
        -H "Content-Type: application/json")

      # Find records starting with _ (ACM validation pattern)
      VAL_ID=$(echo "$VALIDATION_RECORDS" | jq -r \
        --arg domain "$DOMAIN_ROOT" \
        '.result[] | select(.name | startswith("_")) | select(.name | endswith($domain)) | .id' | head -1)

      TF_ADDR="module.environment_network.cloudflare_dns_record.validation[\"${DOMAIN_ROOT}\"]"
      if [[ -n "$VAL_ID" ]] && ! terraform state list 2>/dev/null | grep -qF "cloudflare_dns_record.validation"; then
        echo "   📥 Importing CF validation record for ${DOMAIN_ROOT} (${VAL_ID})"
        terraform import "$TF_ADDR" "${CF_ZONE}/${VAL_ID}" 2>/dev/null && \
          echo "   ✅ Imported CF validation record" || \
          echo "   ⚠️  Could not import CF validation record (will proceed, Terraform may handle it)"
      elif [[ -z "$VAL_ID" ]]; then
        echo "   ℹ️  No existing CF validation record found — Terraform will create it"
      else
        echo "   ✅ CF validation record already in state"
      fi
    else
      echo "   ⚠️  DOMAIN_ROOT not resolvable, skipping CF validation import"
    fi
  else
    echo "   ⚠️ Cloudflare credentials missing. Skipping CF validation import."
  fi

  echo "   🧹 Culling orphaned IAM roles to unblock terraform entity creation..."
  for ROLE in "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-ecs-ec2-cp-instance-role" "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-execution-role" "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-codedeploy-role" "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-task-role" "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-task-execution-role"; do
    if aws iam get-role --role-name "$ROLE" >/dev/null 2>&1; then
      echo "      🗑️ Detaching and deleting role: ${ROLE}"
      for policy_arn in $(aws iam list-attached-role-policies --role-name "$ROLE" --query 'AttachedPolicies[*].PolicyArn' --output text 2>/dev/null || echo ""); do
        [[ -n "$policy_arn" ]] && aws iam detach-role-policy --role-name "$ROLE" --policy-arn "$policy_arn" || true
      done
      for policy_name in $(aws iam list-role-policies --role-name "$ROLE" --query 'PolicyNames[*]' --output text 2>/dev/null || echo ""); do
        [[ -n "$policy_name" ]] && aws iam delete-role-policy --role-name "$ROLE" --policy-name "$policy_name" || true
      done
      for profile_name in $(aws iam list-instance-profiles-for-role --role-name "$ROLE" --query 'InstanceProfiles[*].InstanceProfileName' --output text 2>/dev/null || echo ""); do
        [[ -n "$profile_name" ]] && aws iam remove-role-from-instance-profile --instance-profile-name "$profile_name" --role-name "$ROLE" || true
        [[ -n "$profile_name" ]] && aws iam delete-instance-profile --instance-profile-name "$profile_name" || true
      done
      aws iam delete-role --role-name "$ROLE" || true
    fi
  done

  # ECS Cluster + Capacity Provider — Import Strategy
  # Problem: partial previous runs may leave cluster/CPs in BOTH state AND AWS.
  # The state-guard (! terraform state list | grep cluster) skips cleanup when
  # a prior run partially applied, leaving stale CPs blocking PutClusterCapacityProviders.
  # Solution: unconditionally import existing cluster+CPs into state so Terraform
  # manages them in-place (no conflict), then let apply update them cleanly.
  CLUSTER_NAME="blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-cluster"
  CLUSTER_ARN=$(aws ecs describe-clusters --clusters "$CLUSTER_NAME" --region "$REGION" \
    --query 'clusters[0].clusterArn' --output text 2>/dev/null || echo "")

  if [[ -n "$CLUSTER_ARN" && "$CLUSTER_ARN" != "None" ]]; then
    echo "   🔵 ECS cluster exists in AWS: $CLUSTER_NAME"

    # Import the cluster if not already in state
    CLUSTER_TF_ADDR="module.environment_network.module.cluster.aws_ecs_cluster.main[0]"
    if ! terraform state list 2>/dev/null | grep -qF "aws_ecs_cluster.main"; then
      echo "   📥 Importing ECS cluster into state..."
      terraform import "$CLUSTER_TF_ADDR" "$CLUSTER_ARN" 2>/dev/null && \
        echo "   ✅ Imported ECS cluster" || \
        echo "   ⚠️  Cluster import failed — will attempt cleanup instead"
    else
      echo "   ✅ ECS cluster already in state"
    fi

    # Import or cleanup ECS Capacity Providers
    # cp_ec2 = blaze-*-ec2-cp → module.ec2_capacity_provider[0].aws_ecs_capacity_provider.ec2[0]
    # cp_grav = blaze-*-graviton-cp → module.graviton_cp.aws_ecs_capacity_provider.ec2[0]
    declare -A CP_TF_MAP
    CP_TF_MAP["blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-ec2-cp"]="module.ec2_capacity_provider[0].aws_ecs_capacity_provider.ec2[0]"
    CP_TF_MAP["blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-graviton-cp"]="module.graviton_cp.aws_ecs_capacity_provider.ec2[0]"

    for CP_NAME in "${!CP_TF_MAP[@]}"; do
      CP_TF_ADDR="${CP_TF_MAP[$CP_NAME]}"
      CP_STATUS=$(aws ecs describe-capacity-providers \
        --capacity-providers "$CP_NAME" \
        --region "$REGION" \
        --query 'capacityProviders[0].status' \
        --output text 2>/dev/null || echo "")

      if [[ "$CP_STATUS" == "ACTIVE" ]]; then
        if ! terraform state list 2>/dev/null | grep -qF "$CP_TF_ADDR"; then
          echo "   📥 Importing ECS CP into state: $CP_NAME"
          terraform import "$CP_TF_ADDR" "$CP_NAME" 2>/dev/null && \
            echo "   ✅ Imported CP: $CP_NAME" || \
            echo "   ⚠️  CP import failed for $CP_NAME"
        else
          echo "   ✅ CP already in state: $CP_NAME"
        fi
      elif [[ "$CP_STATUS" == "INACTIVE" ]]; then
        # INACTIVE CPs still block PutClusterCapacityProviders — state-rm them
        echo "   🧹 Removing INACTIVE CP from state if present: $CP_NAME"
        terraform state rm "$CP_TF_ADDR" 2>/dev/null || true
      fi
    done

    # Import cluster capacity providers association if not in state
    CP_ASSOC_TF="module.environment_network.module.cluster.aws_ecs_cluster_capacity_providers.main[0]"
    if ! terraform state list 2>/dev/null | grep -qF "aws_ecs_cluster_capacity_providers"; then
      echo "   📥 Importing ECS cluster capacity providers association..."
      terraform import "$CP_ASSOC_TF" "$CLUSTER_NAME" 2>/dev/null && \
        echo "   ✅ Imported cluster CP association" || \
        echo "   ℹ️  CP association import failed (may not exist yet)"
    fi
  else
    echo "   ℹ️  No existing ECS cluster found — Terraform will create fresh"
  fi

  # Orphan EC2 Launch Template Cleanup
  # pre-destroy.sh state-rm's the LT; AWS retains it; reprovision fails with AlreadyExistsException.
  for LT_NAME in \
    "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-ecs-ec2-cp-lt" \
    "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-graviton-cp-lt"; do
    LT_ID=$(aws ec2 describe-launch-templates \
      --filters "Name=launch-template-name,Values=${LT_NAME}" \
      --region "$REGION" \
      --query 'LaunchTemplates[0].LaunchTemplateId' \
      --output text 2>/dev/null || echo "")
    if [[ -n "$LT_ID" && "$LT_ID" != "None" ]]; then
      # Only delete if not managed by Terraform state
      if ! terraform state list 2>/dev/null | grep -q "aws_launch_template"; then
        echo "   🧹 Deleting orphan Launch Template: $LT_NAME ($LT_ID)"
        aws ec2 delete-launch-template --launch-template-id "$LT_ID" --region "$REGION" && \
          echo "   ✅ Deleted orphan Launch Template: $LT_NAME" || \
          echo "   ⚠️  Could not delete LT $LT_NAME"
      fi
    fi
  done

  # Orphan Auto Scaling Group Cleanup
  # ASG survives nuke when pre-destroy.sh state-rm's it; reprovision fails with AlreadyExists.
  for ASG_NAME in \
    "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-ecs-ec2-cp-asg" \
    "blaze-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-graviton-cp-asg"; do
    ASG_EXISTS=$(aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-names "$ASG_NAME" \
      --region "$REGION" \
      --query 'AutoScalingGroups[0].AutoScalingGroupName' \
      --output text 2>/dev/null || echo "")
    if [[ -n "$ASG_EXISTS" && "$ASG_EXISTS" != "None" ]]; then
      if ! terraform state list 2>/dev/null | grep -q "aws_autoscaling_group"; then
        echo "   🧹 Force-deleting orphan ASG: $ASG_NAME"
        aws autoscaling delete-auto-scaling-group \
          --auto-scaling-group-name "$ASG_NAME" \
          --force-delete \
          --region "$REGION" && \
          echo "   ✅ Deleted orphan ASG: $ASG_NAME" || \
          echo "   ⚠️  Could not delete ASG $ASG_NAME"
      fi
    fi
  done


elif [[ "$STACK" == "tunnel" || "$STACK" == "third-party-cloudflare" ]]; then
  echo "🔍 Running Tunnel/Cloudflare Smart Import Logic..."
  
  # Import Cloudflare Pages Custom Domain for admin
  if [[ -n "$TF_VAR_cloudflare_account_id" && -n "$TF_VAR_cloudflare_api_token" ]]; then
     NAMESPACE="${INPUT_NAMESPACE:-blaze}"
     CLIENT_KEY="${INPUT_CLIENT_KEY}"
     PROJECT_KEY="${INPUT_PROJECT_KEY}"
     STAGE_KEY="${INPUT_STAGE_KEY}"
     DOMAIN_ROOT="${INPUT_DOMAIN_ROOT}"
     
     PROJECT_NAME="${NAMESPACE}-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}-admin"
     DOMAIN="admin-${STAGE_KEY}.${DOMAIN_ROOT}"
     ACCOUNT_ID="$TF_VAR_cloudflare_account_id"

     echo "   Checking if domain $DOMAIN is already attached to project $PROJECT_NAME..."
     
     # Check if domain exists via Cloudflare API
     RESPONSE=$(curl -s -X GET \
       "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT_NAME}/domains/${DOMAIN}" \
       -H "Authorization: Bearer $TF_VAR_cloudflare_api_token")
     
     SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
     
     if [[ "$SUCCESS" == "true" ]]; then
        echo "   ✅ Domain $DOMAIN is already attached"
        
        if ! terraform state list | grep -q "module.admin_pages_domain.cloudflare_pages_domain.this"; then
           IMPORT_ID="${ACCOUNT_ID}/${PROJECT_NAME}/${DOMAIN}"
           echo "   📥 Importing Cloudflare Pages Domain into Terraform state"
           echo "      Resource: module.admin_pages_domain.cloudflare_pages_domain.this"
           echo "      ID: $IMPORT_ID"
           terraform import 'module.admin_pages_domain.cloudflare_pages_domain.this' "$IMPORT_ID" || echo "   ⚠️ Import failed (may already be in state)"
        else
           echo "   ℹ️  Domain already in Terraform state"
        fi
     else
        echo "   ℹ️  Domain not yet attached. Terraform will create it."
     fi
  else
     echo "   ⚠️ Cloudflare credentials missing. Skipping import."
  fi

elif [[ "$STACK" == "app" || "$STACK" == "cdn" ]]; then
  echo "🔍 Running App/CDN Smart Import & Cleanup Logic..."

  # Cloudflare Pages Custom Domain (App only)
  if [[ "$STACK" == "app" && -n "$TF_VAR_cloudflare_account_id" && -n "$TF_VAR_project_key" && -n "$TF_VAR_stage" ]]; then
     NAMESPACE="${INPUT_NAMESPACE:-blaze}"
     PROJECT_NAME="${NAMESPACE}-${TF_VAR_project_key}-${TF_VAR_stage}-admin"
     DOMAIN="admin-${TF_VAR_stage}.${TF_VAR_domain_root}"
     ACCOUNT_ID="$TF_VAR_cloudflare_account_id"

     if [[ "$ACCOUNT_ID" != "dummy" ]]; then
        IMPORT_ID="${ACCOUNT_ID}/${PROJECT_NAME}/${DOMAIN}"

        if ! terraform state list | grep -q "cloudflare_pages_domain.admin"; then
           echo "📥 Importing Cloudflare Pages Domain: $DOMAIN"
           echo "   ID: $IMPORT_ID"
           terraform import cloudflare_pages_domain.admin "$IMPORT_ID" || echo "   ⚠️ Import failed (or already imported)"
        fi
     else
        echo "   ⚠️ Cloudflare Account ID is dummy. Skipping CF Pages import."
     fi
  fi

  # DNS Cleanup (App and CDN) - Prevents Cloudflare v5 "already exists" errors since allow_overwrite was removed
  if [[ -n "$TF_VAR_cloudflare_api_token" && -n "$TF_VAR_cloudflare_zone_id" && -n "$INPUT_STAGE_KEY" && -n "$INPUT_DOMAIN_ROOT" ]]; then
     echo "   🧹 Checking for existing DNS records to prevent 'already exists' errors..."
     STAGE_KEY="${INPUT_STAGE_KEY}"
     DOMAIN_ROOT="${INPUT_DOMAIN_ROOT}"
     
     TARGET_RECORDS=(
       "gcp-${STAGE_KEY}.${DOMAIN_ROOT}"
       "api-gcp-${STAGE_KEY}.${DOMAIN_ROOT}"
       "frontend-gcp-${STAGE_KEY}.${DOMAIN_ROOT}"
     )

     for RECORD in "${TARGET_RECORDS[@]}"; do
        RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$TF_VAR_cloudflare_zone_id/dns_records?name=$RECORD" \
          -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
          -H "Content-Type: application/json")

        RECORD_ID=$(echo "$RESPONSE" | jq -r '.result[0].id // empty')

        if [[ -n "$RECORD_ID" ]]; then
           echo "   🗑️ Deleting pre-existing record: $RECORD ($RECORD_ID)"
           curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$TF_VAR_cloudflare_zone_id/dns_records/$RECORD_ID" \
             -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
             -H "Content-Type: application/json" > /dev/null
        fi
     done
  fi

else
  echo "ℹ️ No smart import logic defined for stack: $STACK"
fi
# Cloudflare Zero Trust Access Application Cleanup
if [[ -n "$TF_VAR_cloudflare_api_token" && -n "$TF_VAR_cloudflare_zone_id" && -n "$TF_VAR_cloudflare_account_id" ]]; then
  echo "   🧹 Culling conflicting Cloudflare Access Applications..."
  # Fetch all access apps for the account
  APPS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$TF_VAR_cloudflare_account_id/access/apps" \
    -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
    -H "Content-Type: application/json")

  # We strictly cull apps in this environment (admin, frontend, api)
  # Name usually looks like project-env-role, or we can just check 'domain' containing "stage.domain.com"
  STAGE_KEY="${INPUT_STAGE_KEY}"
  DOMAIN_ROOT="${INPUT_DOMAIN_ROOT}"

  for APP_ROLE in "admin" "frontend" "api" "grafana" "kibana"; do
    TARGET_DOMAIN="${APP_ROLE}-${STAGE_KEY}.${DOMAIN_ROOT}"
    # Sometimes it's admin-stage.domain.com, api-stage.domain.com
    APP_ID=$(echo "$APPS" | jq -r ".result[]? | select(.domain == \"$TARGET_DOMAIN\") | .id // empty")
    
    if [[ -n "$APP_ID" ]]; then
      echo "      🗑️ Deleting Zero Trust App: $TARGET_DOMAIN ($APP_ID)"
      curl -s -X DELETE "https://api.cloudflare.com/client/v4/accounts/$TF_VAR_cloudflare_account_id/access/apps/$APP_ID" \
        -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
        -H "Content-Type: application/json" > /dev/null
    fi
  done
  
  # Also cull the root CNAME or CNAME validations just in case it clashes
  echo "   🧹 Doing aggressive DNS collision cleanup for ${STAGE_KEY}.${DOMAIN_ROOT}..."
  for TYPE in A AAAA CNAME TXT; do
    ALL_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$TF_VAR_cloudflare_zone_id/dns_records?type=$TYPE&per_page=100" \
      -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
      -H "Content-Type: application/json")
    
    # We selectively delete any record that STARTS with an underscore (validation records)
    # OR exactly matches our main domains
    BAD_REC_IDS=$(echo "$ALL_RECORDS" | jq -r ".result[]? | select(.name | startswith(\"_\")) | .id // empty")
    for ID in $BAD_REC_IDS; do
      NAME=$(echo "$ALL_RECORDS" | jq -r ".result[] | select(.id==\"$ID\") | .name")
      echo "      🗑️ Deleting validation record: $NAME ($TYPE) ($ID)"
      curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$TF_VAR_cloudflare_zone_id/dns_records/$ID" \
        -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" > /dev/null
    done
  done
fi
