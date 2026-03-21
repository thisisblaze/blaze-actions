#!/bin/bash
set -e

# ==============================================================================
# SCRIPT: check-vpc-integrity.sh
# PURPOSE: Prevent Terraform from creating duplicate VPCs by verifying consistency
#          between AWS reality and Terraform State.
# USAGE:   ./check-vpc-integrity.sh [region]
# ENV:     AWS_REGION, CLIENT_KEY, PROJECT_KEY, STAGE
# ==============================================================================

# 1. Configuration
REGION="${1:-${AWS_REGION:-eu-west-1}}"
CLIENT="${CLIENT_KEY:-b9}"
PROJECT="${PROJECT_KEY:-thisisblaze}"
# Default to 'stage' if not set, or extract from directory name if possible
STAGE="${STAGE:-stage}"

NAMESPACE="${NAMESPACE:-blaze}"
VPC_NAME="${NAMESPACE}-${CLIENT}-${PROJECT}-${STAGE}-vpc"
TF_RESOURCE="module.environment_network.module.networking.module.vpc.aws_vpc.this[0]"

echo "---------------------------------------------------"
echo "🔍 VPC Integrity Check"
echo "   Region:   $REGION"
echo "   VPC Name: $VPC_NAME"
echo "---------------------------------------------------"

# 2. Check AWS (Reality)
echo "☁️  Checking AWS for existing VPCs..."
VPC_IDS=$(aws ec2 describe-vpcs \
  --region "$REGION" \
  --filters "Name=tag:Name,Values=$VPC_NAME" "Name=state,Values=available" \
  --query "Vpcs[*].VpcId" \
  --output text)

# Convert space-separated string to array
IFS=$'\t\n ' read -r -a UPSTREAM_VPCS <<< "$VPC_IDS"
UPSTREAM_COUNT=${#UPSTREAM_VPCS[@]}

echo "   Found $UPSTREAM_COUNT VPC(s): ${UPSTREAM_VPCS[*]}"

# 3. Check Terraform State (Expectation)
echo "📄 Checking Terraform State..."
IN_STATE=false
STATE_ID=""

if terraform state list | grep -qF "$TF_RESOURCE"; then
  IN_STATE=true
  # Try to get the ID from state (might fail if state is corrupt/empty, suppress error)
  STATE_ID=$(terraform state show "$TF_RESOURCE" 2>/dev/null | grep -E '^id\s+=' | awk -F'=' '{print $2}' | tr -d ' "')
  echo "   VPC is in Terraform State (ID: $STATE_ID)"
else
  echo "   VPC is NOT in Terraform State."
fi

# 4. Integrity Logic & Decision
echo "---------------------------------------------------"
echo "⚖️  Verdict:"

# CASE A: CLEAN SLATE (0 in AWS, 0 in State)
if [[ $UPSTREAM_COUNT -eq 0 && "$IN_STATE" == "false" ]]; then
  echo "✅ CLEAN SLATE: No existing VPCs found. Safe to provision."
  exit 0
fi

# CASE B: SYNCED (1 in AWS, In State, IDs Match)
if [[ $UPSTREAM_COUNT -eq 1 && "$IN_STATE" == "true" ]]; then
  # Simple ID match check if we managed to grab the state ID
  if [[ -n "$STATE_ID" && "${UPSTREAM_VPCS[0]}" != "$STATE_ID" ]]; then
      echo "❌ CRITICAL: State Mismatch!"
      echo "   AWS ID:   ${UPSTREAM_VPCS[0]}"
      echo "   State ID: $STATE_ID"
      echo "   Terraform thinks it manages a different VPC than the one in AWS."
      echo "   ACTION: Destroy the AWS one manually or fix state."
      exit 1
  fi
  echo "✅ SYNCED: VPC exists and is tracked by Terraform. Safe to update."
  exit 0
fi

# CASE C: ORPHANED / UNTRACKED (1 in AWS, Not in State) -> AUTO-IMPORT
if [[ $UPSTREAM_COUNT -eq 1 && "$IN_STATE" == "false" ]]; then
  echo "⚠️  ORPHANED VPC: exists in AWS but missing from Terraform State."
  echo "   AWS ID: ${UPSTREAM_VPCS[0]}"
  echo "   Terraform apply would create a DUPLICATE — auto-importing instead."
  echo "   Command: terraform import '$TF_RESOURCE' ${UPSTREAM_VPCS[0]}"
  # Suppress interactive prompts for secrets not available in this context
  # (import only touches the VPC resource; these vars are not exercised)
  # Cloudflare api_token must be exactly 40 alphanumeric/hyphen/underscore chars
  export TF_VAR_cloudflare_api_token="${TF_VAR_cloudflare_api_token:-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}"
  export TF_VAR_cloudflare_zone_id="${TF_VAR_cloudflare_zone_id:-00000000000000000000000000000000}"
  export TF_VAR_cloudflare_account_id="${TF_VAR_cloudflare_account_id:-00000000000000000000000000000000}"
  if terraform import "$TF_RESOURCE" "${UPSTREAM_VPCS[0]}"; then
    echo "✅ VPC imported successfully. Safe to continue with apply."
    exit 0
  else
    echo "❌ CRITICAL: Auto-import failed. Manual intervention required."
    echo "   Run: terraform import '$TF_RESOURCE' ${UPSTREAM_VPCS[0]}"
    exit 1
  fi
fi

# CASE D: DUPLICATES / MESS (>1 in AWS)
if [[ $UPSTREAM_COUNT -gt 1 ]]; then
  echo "❌ CRITICAL: Multiple VPCs with name '$VPC_NAME' found!"
  echo "   IDs: ${UPSTREAM_VPCS[*]}"
  echo "   Terraform cannot determine which one to manage."
  echo "   ACTION: Manually delete the duplicates in the AWS Console ($REGION)."
  exit 1
fi

# Fallback (Should happen if logic covers all cases)
echo "✅ Check passed (Logic fallthrough). Proceeding with caution."
exit 0
