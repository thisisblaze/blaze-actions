#!/bin/bash
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
