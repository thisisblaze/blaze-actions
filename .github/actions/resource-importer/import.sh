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
  # Guard: terraform may not be installed in the Configuration job — skip import, AWS-delete only.
  TF_AVAILABLE=false
  command -v terraform > /dev/null 2>&1 && TF_AVAILABLE=true

  for TG in admin-blue admin-green fe-blue fe-green api-blue api-green; do
    RESOURCE_NAME=$(echo "$TG" | sed 's/fe-/frontend_/' | tr '-' '_')
    TG_NAME="blaze-${STAGE_KEY}-${TG}-tg"
    TG_ARN=$(aws elbv2 describe-target-groups --names "$TG_NAME" --region "$REGION" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")

    if [[ -n "$TG_ARN" && "$TG_ARN" != "None" ]]; then
      ALREADY_IN_STATE=false
      if [[ "$TF_AVAILABLE" == "true" ]]; then
        terraform state list 2>/dev/null | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}" && ALREADY_IN_STATE=true
      fi

      if [[ "$ALREADY_IN_STATE" != "true" ]]; then
        IMPORTED=false
        if [[ "$TF_AVAILABLE" == "true" ]]; then
          echo "📥 Importing target group: $TG_NAME"
          terraform import "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}[0]" "$TG_ARN" 2>/dev/null && IMPORTED=true || true
          # Re-check state after import attempt
          terraform state list 2>/dev/null | grep -q "module.environment_network.aws_lb_target_group.${RESOURCE_NAME}" && IMPORTED=true
        fi

        if [[ "$IMPORTED" != "true" ]]; then
          # Check if TG is attached to a listener before deleting — ResourceInUse if so
          LISTENERS=$(aws elbv2 describe-listeners \
            --query "Listeners[?DefaultActions[?TargetGroupArn=='${TG_ARN}']].ListenerArn" \
            --output text 2>/dev/null || echo "")
          RULES=$(aws elbv2 describe-rules \
            --listener-arn "$(aws elbv2 describe-listeners --region "$REGION" \
              --query 'Listeners[0].ListenerArn' --output text 2>/dev/null || echo "none")" \
            --region "$REGION" \
            --query "Rules[?Actions[?TargetGroupArn=='${TG_ARN}']].RuleArn" \
            --output text 2>/dev/null || echo "") 2>/dev/null || true
          if [[ -n "$LISTENERS" && "$LISTENERS" != "None" ]]; then
            echo "   ⚠️  Skipping delete of $TG_NAME — still referenced by a listener (will be replaced by apply)"
          else
            echo "   ⚠️  Deleting orphan TG from AWS: $TG_NAME"
            aws elbv2 delete-target-group --target-group-arn "$TG_ARN" --region "$REGION" && \
              echo "   ✅ Deleted orphan TG: $TG_NAME" || \
              echo "   ⚠️  Could not delete $TG_NAME (may have active dependencies)"
          fi
        fi
      else
        echo "   ✅ TG already in state: $TG_NAME"
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

  # ── DNS Records Import-First Pass (network / multi-site-network) ──────────────
  # Cloudflare provider v5 removed allow_overwrite. Records that exist in CF but
  # are absent from TF state cause terraform to POST (create) → 81053 AlreadyExists.
  # Fix: import existing records into state before apply → TF issues PATCH (update),
  # not POST → no conflict, no downtime, fully idempotent.
  #
  # Record name logic mirrors environment-network module locals exactly:
  #   is_prod = stage == "prod"
  #   api_record_name   = is_prod ? "api"       : "api-${stage}"
  #   fe_record_name    = is_prod ? "@"          : "frontend-${stage}"
  #   admin_record_name = is_prod ? "admin"      : "admin-${stage}"
  #   cdn_record_name   = is_prod ? "cdn"        : "cdn-${stage}"
  #   api_direct        = prod → "api-direct" | non-prod → "api-direct-${stage}"
  #                     (v2.2.29: api_direct_subdomain_override removed -prod suffix)
  # Note: CF stores apex "@" as the bare DOMAIN_ROOT (e.g. "thisisblaze.uk").
  if [[ -n "$TF_VAR_cloudflare_api_token" && -n "$TF_VAR_cloudflare_zone_id" && -n "$INPUT_STAGE_KEY" && -n "$INPUT_DOMAIN_ROOT" ]]; then
    echo "   🔵 DNS import-first pass for managed network/multi-site-network DNS records..."
    STAGE_KEY="${INPUT_STAGE_KEY}"
    DOMAIN_ROOT="${INPUT_DOMAIN_ROOT}"
    CF_ZONE="$TF_VAR_cloudflare_zone_id"

    IS_PROD=false
    [[ "$STAGE_KEY" == "prod" ]] && IS_PROD=true

    if [[ "$IS_PROD" == "true" ]]; then
      API_RECORD="api.${DOMAIN_ROOT}"
      FE_RECORD="${DOMAIN_ROOT}"               # apex @
      ADMIN_RECORD="admin.${DOMAIN_ROOT}"
      CDN_RECORD="cdn.${DOMAIN_ROOT}"
      # v2.2.29: api-direct in prod drops the -prod suffix (api_direct_subdomain_override)
      API_DIRECT_RECORD="api-direct.${DOMAIN_ROOT}"
    else
      API_RECORD="api-${STAGE_KEY}.${DOMAIN_ROOT}"
      FE_RECORD="frontend-${STAGE_KEY}.${DOMAIN_ROOT}"
      ADMIN_RECORD="admin-${STAGE_KEY}.${DOMAIN_ROOT}"
      CDN_RECORD="cdn-${STAGE_KEY}.${DOMAIN_ROOT}"
      API_DIRECT_RECORD="api-direct-${STAGE_KEY}.${DOMAIN_ROOT}"
    fi

    # Map: CF record name (as stored in Cloudflare) → Terraform state address
    declare -A NET_DNS_TF_MAP
    NET_DNS_TF_MAP["$API_RECORD"]="module.environment_network.cloudflare_dns_record.api[0]"
    NET_DNS_TF_MAP["$FE_RECORD"]="module.environment_network.cloudflare_dns_record.frontend[0]"
    NET_DNS_TF_MAP["$ADMIN_RECORD"]="module.environment_network.cloudflare_dns_record.admin[0]"
    NET_DNS_TF_MAP["$CDN_RECORD"]="module.environment_network.cloudflare_dns_record.cdn[0]"
    NET_DNS_TF_MAP["$API_DIRECT_RECORD"]="module.environment_network.cloudflare_dns_record.api_direct[0]"

    for RECORD_NAME in "${!NET_DNS_TF_MAP[@]}"; do
      TF_ADDR="${NET_DNS_TF_MAP[$RECORD_NAME]}"
      RESPONSE=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records?name=${RECORD_NAME}" \
        -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
        -H "Content-Type: application/json")
      RECORD_ID=$(echo "$RESPONSE" | jq -r '.result[0].id // empty' 2>/dev/null || true)

      if [[ -n "$RECORD_ID" ]]; then
        if ! terraform state list 2>/dev/null | grep -qF "$TF_ADDR"; then
          echo "   📥 Importing DNS record: ${RECORD_NAME} → ${TF_ADDR}"
          terraform import "$TF_ADDR" "${CF_ZONE}/${RECORD_ID}" 2>/dev/null && \
            echo "   ✅ Imported: ${RECORD_NAME}" || \
            echo "   ⚠️  Import failed for ${RECORD_NAME} — TF will attempt create (may conflict if record exists)"
        else
          echo "   ✅ Already in state: ${RECORD_NAME}"
        fi
      else
        echo "   ℹ️  Not found in Cloudflare: ${RECORD_NAME} (TF will create fresh)"
      fi
    done
  else
    echo "   ⚠️ Cloudflare credentials or stage/domain missing — skipping DNS import-first pass."
  fi
  # ─────────────────────────────────────────────────────────────────────────────

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

    # Import or cleanup ECS Capacity Providers — dynamically discover from cluster
    ALL_CP_NAMES=$(aws ecs describe-clusters --clusters "$CLUSTER_NAME" --region "$REGION" \
      --include CONFIGURATIONS \
      --query 'clusters[0].capacityProviders' --output text 2>/dev/null || echo "")
    echo "   🔍 CPs attached to cluster: ${ALL_CP_NAMES:-none}"
    for CP_NAME in $ALL_CP_NAMES; do
      [[ "$CP_NAME" == "FARGATE" || "$CP_NAME" == "FARGATE_SPOT" ]] && continue
      CP_STATUS=$(aws ecs describe-capacity-providers \
        --capacity-providers "$CP_NAME" \
        --region "$REGION" \
        --query 'capacityProviders[0].status' \
        --output text 2>/dev/null || echo "")
      if [[ "$CP_STATUS" == "ACTIVE" ]]; then
        # Try both known module addresses — observed: module.graviton_cp creates -ecs-ec2-cp
        IMPORTED_CP=false
        for CP_TF_ADDR in \
          "module.graviton_cp.aws_ecs_capacity_provider.ec2[0]" \
          "module.ec2_capacity_provider[0].aws_ecs_capacity_provider.ec2[0]"; do
          if ! terraform state list 2>/dev/null | grep -qF "$CP_TF_ADDR"; then
            echo "   📥 Trying import: $CP_NAME → $CP_TF_ADDR"
            if terraform import "$CP_TF_ADDR" "$CP_NAME" 2>/dev/null; then
              echo "   ✅ Imported CP: $CP_NAME → $CP_TF_ADDR"
              IMPORTED_CP=true
              break
            fi
          else
            echo "   ✅ CP already in state: $CP_TF_ADDR"
            IMPORTED_CP=true
            break
          fi
        done
        if [[ "$IMPORTED_CP" != "true" ]]; then
          echo "   ⚠️  Could not import CP: $CP_NAME into any known address"
        fi
      elif [[ "$CP_STATUS" == "INACTIVE" ]]; then
        # INACTIVE CPs still block PutClusterCapacityProviders — state-rm both possible addresses
        echo "   🧹 Removing INACTIVE CP from state if present: $CP_NAME"
        terraform state rm "module.graviton_cp.aws_ecs_capacity_provider.ec2[0]" 2>/dev/null || true
        terraform state rm "module.ec2_capacity_provider[0].aws_ecs_capacity_provider.ec2[0]" 2>/dev/null || true
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

  # DNS — Import-first strategy for managed records
  # Cloudflare v5 removed allow_overwrite, so TF fails if a record exists but is not in state.
  # Import-first: pull existing records into state → TF sees no drift → no downtime, no race condition.
  # Delete is used only for records with no known TF address (genuine orphans).
  if [[ -n "$TF_VAR_cloudflare_api_token" && -n "$TF_VAR_cloudflare_zone_id" && -n "$INPUT_STAGE_KEY" && -n "$INPUT_DOMAIN_ROOT" ]]; then
    echo "   🔵 DNS import-first pass for managed GCP/CDN records..."
    STAGE_KEY="${INPUT_STAGE_KEY}"
    DOMAIN_ROOT="${INPUT_DOMAIN_ROOT}"
    CF_ZONE="$TF_VAR_cloudflare_zone_id"

    # Map: record name → Terraform address
    # Extend this map when infra-core adds new managed dns_record resources
    declare -A DNS_TF_MAP
    DNS_TF_MAP["gcp-${STAGE_KEY}.${DOMAIN_ROOT}"]="module.environment_network.cloudflare_dns_record.gcp[0]"
    DNS_TF_MAP["api-gcp-${STAGE_KEY}.${DOMAIN_ROOT}"]="module.environment_network.cloudflare_dns_record.api_gcp[0]"
    DNS_TF_MAP["frontend-gcp-${STAGE_KEY}.${DOMAIN_ROOT}"]="module.environment_network.cloudflare_dns_record.frontend_gcp[0]"
    DNS_TF_MAP["cdn-${STAGE_KEY}.${DOMAIN_ROOT}"]="module.environment_network.cloudflare_dns_record.cdn[0]"
    DNS_TF_MAP["frontend-${STAGE_KEY}.${DOMAIN_ROOT}"]="module.environment_network.cloudflare_dns_record.frontend[0]"
    DNS_TF_MAP["api-${STAGE_KEY}.${DOMAIN_ROOT}"]="module.environment_network.cloudflare_dns_record.api[0]"

    for RECORD_NAME in "${!DNS_TF_MAP[@]}"; do
      TF_ADDR="${DNS_TF_MAP[$RECORD_NAME]}"
      RESPONSE=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records?name=${RECORD_NAME}" \
        -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
        -H "Content-Type: application/json")
      RECORD_ID=$(echo "$RESPONSE" | jq -r '.result[0].id // empty')

      if [[ -n "$RECORD_ID" ]]; then
        if ! terraform state list 2>/dev/null | grep -qF "$TF_ADDR"; then
          echo "   📥 Importing DNS record: ${RECORD_NAME} → ${TF_ADDR}"
          terraform import "$TF_ADDR" "${CF_ZONE}/${RECORD_ID}" 2>/dev/null && \
            echo "   ✅ Imported: ${RECORD_NAME}" || \
            echo "   ⚠️  Import failed for ${RECORD_NAME} — TF will attempt create (may fail if name conflicts)"
        else
          echo "   ✅ Already in state: ${RECORD_NAME}"
        fi
      else
        echo "   ℹ️  Not found in Cloudflare: ${RECORD_NAME} (will be created fresh)"
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
  
  # ACM validation CNAMEs (_acme-challenge.* / _*.domain) — import-first, delete only if unimportable
  # These start with '_' and are managed by cloudflare_dns_record.validation["domain"]
  echo "   🔵 Checking _* validation records (import-first)..."
  STAGE_KEY="${INPUT_STAGE_KEY:-}"
  DOMAIN_ROOT="${INPUT_DOMAIN_ROOT:-}"
  CF_ZONE="$TF_VAR_cloudflare_zone_id"
  ALL_VAL=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records?type=CNAME&per_page=100" \
    -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
    -H "Content-Type: application/json")
  VAL_IDS=$(echo "$ALL_VAL" | jq -r '.result[]? | select(.name | startswith("_")) | .id')
  for ID in $VAL_IDS; do
    NAME=$(echo "$ALL_VAL" | jq -r ".result[] | select(.id==\"$ID\") | .name")
    # Determine the domain root this record belongs to (strip leading _acme-challenge. or similar)
    REC_DOMAIN=$(echo "$NAME" | sed 's/^_[^.]*\.//')
    TF_ADDR="module.environment_network.cloudflare_dns_record.validation[\"${REC_DOMAIN}\"]"
    if ! terraform state list 2>/dev/null | grep -qF "cloudflare_dns_record.validation[\"${REC_DOMAIN}\"]"; then
      echo "   📥 Importing validation record: ${NAME} → ${TF_ADDR}"
      terraform import "$TF_ADDR" "${CF_ZONE}/${ID}" 2>/dev/null && \
        echo "   ✅ Imported validation: ${NAME}" || {
        # Import failed (wrong TF address) — only then delete as last resort
        echo "   🗑️  Import failed — deleting unimportable validation record: ${NAME} (${ID})"
        curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/dns_records/${ID}" \
          -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" > /dev/null
      }
    else
      echo "   ✅ Validation record already in state: ${NAME}"
    fi
  done
fi
