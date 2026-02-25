#!/bin/bash
set -e

# Smart pre-destroy script for MongoDB Atlas
# Automatically disables termination protection before destroying cluster

# Variables from Terraform/Workflow
CLIENT_KEY="${TF_VAR_client_key:-}"
NAMESPACE="${TF_VAR_namespace:-}"
PLATFORM="${TF_VAR_platform:-}"
STAGE="${TF_VAR_stage:-}"

# Calculate cluster name (matches Terraform module logic)
# Pattern: ${namespace}-${client_key}-${platform}-${stage}
CLUSTER_NAME="${NAMESPACE}-${CLIENT_KEY}-${PLATFORM}-${STAGE}"
# Variables from Terraform/Workflow (moved to fallback logic)

# MongoDB Atlas credentials - try TF_VAR_ first, then direct env vars
PROJECT_ID="${TF_VAR_atlas_project_id:-${MONGODB_ATLAS_PROJECT_ID:-}}"
PUBLIC_KEY="${TF_VAR_atlas_public_key:-${MONGODB_ATLAS_PUBLIC_KEY:-}}"
PRIVATE_KEY="${TF_VAR_atlas_private_key:-${MONGODB_ATLAS_PRIVATE_KEY:-}}"

# Get actual cluster name from Terraform state (includes random suffix)
CLUSTER_NAME=""
if command -v terraform &> /dev/null; then
  # Extract cluster name from state using jq
  CLUSTER_NAME=$(terraform state show 'module.mongodb_cluster.mongodbatlas_cluster.main' 2>/dev/null | grep -E '^\s*name\s*=' | awk -F'"' '{print $2}' || echo "")
  
  if [ -z "$CLUSTER_NAME" ]; then
    # Fallback: try to get from state list
    echo "⚠️  Could not extract cluster name from terraform state show, trying state list..."
    CLUSTER_NAME=$(terraform state list 2>/dev/null | grep 'mongodbatlas_cluster.main' | head -1 || echo "")
  fi
fi

# If still empty, calculate as fallback (won't include random suffix but better than nothing)
if [ -z "$CLUSTER_NAME" ]; then
  CLIENT_KEY="${TF_VAR_client_key:-}"
  NAMESPACE="${TF_VAR_namespace:-}"
  PLATFORM="${TF_VAR_platform:-}"
  STAGE="${TF_VAR_stage:-}"
  CLUSTER_NAME="${NAMESPACE}-${CLIENT_KEY}-${PLATFORM}-${STAGE}"
  echo "⚠️  Using calculated cluster name (may not include random suffix): $CLUSTER_NAME"
fi

echo "🔍 Debug credentials:"
echo "   Cluster name: $CLUSTER_NAME"
echo "   Project ID: $([ -n "$PROJECT_ID" ] && echo 'SET' || echo 'MISSING')"
echo "   Public Key: $([ -n "$PUBLIC_KEY" ] && echo 'SET' || echo 'MISSING')"
echo "   Private Key: $([ -n "$PRIVATE_KEY" ] && echo 'SET' || echo 'MISSING')"

if [ -z "$PROJECT_ID" ] || [ -z "$PUBLIC_KEY" ] || [ -z "$PRIVATE_KEY" ]; then
  echo "❌ MongoDB Atlas credentials incomplete - cannot disable termination protection"
  echo "   This is not critical - you can manually disable it in Atlas Console"
  exit 0
fi

echo "🔍 Checking if cluster '$CLUSTER_NAME' exists..."

# Check if cluster exists
CLUSTER_EXISTS=$(curl -s -u "${PUBLIC_KEY}:${PRIVATE_KEY}" \
  "https://cloud.mongodb.com/api/atlas/v1.0/groups/${PROJECT_ID}/clusters/${CLUSTER_NAME}" \
  -w "%{http_code}" -o /tmp/cluster_response.json)

if [ "$CLUSTER_EXISTS" != "200" ]; then
  echo "✅ Cluster does not exist - nothing to do"
  exit 0
fi

# Get current termination protection status
TERMINATION_PROTECTION=$(cat /tmp/cluster_response.json | jq -r '.terminationProtectionEnabled // false')

if [ "$TERMINATION_PROTECTION" = "false" ]; then
  echo "✅ Termination protection already disabled"
  exit 0
fi

echo "🔧 Disabling termination protection for cluster '$CLUSTER_NAME'..."

# Disable termination protection
RESPONSE=$(curl -s -u "${PUBLIC_KEY}:${PRIVATE_KEY}" \
  -X PATCH \
  "https://cloud.mongodb.com/api/atlas/v1.0/groups/${PROJECT_ID}/clusters/${CLUSTER_NAME}" \
  -H "Content-Type: application/json" \
  -d '{"terminationProtectionEnabled": false}' \
  -w "%{http_code}" -o /tmp/disable_response.json)

if [ "$RESPONSE" = "200" ]; then
  echo "✅ Termination protection disabled successfully"
  echo "   Cluster is now ready for destruction"
else
  echo "⚠️  Failed to disable termination protection (HTTP $RESPONSE)"
  cat /tmp/disable_response.json
  echo ""
  echo "   This is not critical - Terraform will fail and you can manually disable"
  # Don't exit with error - let Terraform proceed and fail with helpful message
fi

exit 0
