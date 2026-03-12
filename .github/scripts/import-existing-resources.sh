
#!/bin/bash
set -eo pipefail

echo "=================================================="
echo " 🧹 Pre-Apply Cleanup & Import"
echo "=================================================="

# 1. FORCE NEW LAMBDA@EDGE SUFFIX IF LAMBDA WAS ORPHANED
# If the random_id suffix is in state but the function isn't (due to 99-ops-nuke orphaning),
# we must remove the random_id from state so Terraform generates a NEW suffix and avoids 409 Conflict.
if terraform state list | grep -q "lambda_edge_image_resize\[0\]\.random_id\.suffix"; then
  if ! terraform state list | grep -q "lambda_edge_image_resize\[0\]\.aws_lambda_function\.origin_response"; then
    echo "⚠️ Lambda@Edge function is missing from state but random suffix remains."
    echo "🧹 Removing stale random_id.suffix to force generation of a new Lambda name..."
    terraform state rm "module.environment_network.module.lambda_edge_image_resize[0].random_id.suffix" || true
  fi
fi

# Auto-import existing ECR repositories to prevent "already exists" errors
# This script runs before terraform apply to gracefully handle orphaned resources

set +e  # Don't fail on errors - we want to continue even if imports fail

echo "🔍 Checking for existing ECR repositories to import..."

# Only run for network stack (where ECR repos are created)
if [[ "${TF_VAR_stage}" != "network" ]] && [[ ! -f "main.tf" ]] || ! grep -q "module.ecr" main.tf 2>/dev/null; then
  echo "ℹ️  Not a network stack or no ECR module found, skipping ECR import"
  exit 0
fi

# Common ECR repository names
REPOS=(
  "blaze-thisisblaze-web/thisisblaze/api"
  "blaze-thisisblaze-web/thisisblaze/frontend"
  "blaze-thisisblaze-web/thisisblaze/admin"
)

IMPORTED=0
SKIPPED=0

for repo in "${REPOS[@]}"; do
  echo "  Checking: $repo"
  
  # Check if repo exists in AWS
  if aws ecr describe-repositories --repository-names "$repo" --region "${AWS_REGION:-eu-west-1}" >/dev/null 2>&1; then
    echo "    ✓ Repository exists in AWS, attempting import..."
    
    # Try to import into terraform state
    # The resource path might vary, try common patterns
    IMPORT_TARGETS=(
      "module.environment_network.module.ecr.aws_ecr_repository.this[\\\"$repo\\\"]"
      "module.ecr.aws_ecr_repository.this[\\\"$repo\\\"]"
    )
    
    for target in "${IMPORT_TARGETS[@]}"; do
      if terraform import "$target" "$repo" 2>&1 | grep -q "successfully imported"; then
        echo "    ✅ Successfully imported: $repo"
        IMPORTED=$((IMPORTED + 1))
        break
      fi
    done
  else
    echo "    ⏭️  Repository doesn't exist yet, will be created"
    SKIPPED=$((SKIPPED + 1))
  fi
done

echo ""
echo "📊 Import Summary:"
echo "   - Imported: $IMPORTED"
echo "   - Skipped: $SKIPPED"
echo ""

# Always exit 0 - imports are best-effort
exit 0
