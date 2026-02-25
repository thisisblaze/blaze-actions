#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# GCP Bootstrap Script
# ─────────────────────────────────────────────────────────────
# Automates the 3-step GCP bootstrap:
#   1. Create GCS bucket for Terraform state
#   2. Create Workload Identity Federation for GitHub Actions
#   3. Set GitHub repo secrets
#
# Prerequisites:
#   - gcloud CLI authenticated (`gcloud auth login`)
#   - GCP project already created (with billing enabled)
#   - gh CLI authenticated (for setting secrets)
#   - Terraform installed
#
# Usage:
#   ./bootstrap-gcp.sh <GCP_PROJECT_ID> [REGION] [NAMESPACE] [CLIENT_KEY]
#
# Example:
#   ./bootstrap-gcp.sh blaze-b9-thisisblaze europe-west1 blaze b9
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# ── Args ──
GCP_PROJECT_ID="${1:?Usage: $0 <GCP_PROJECT_ID> [REGION] [NAMESPACE] [CLIENT_KEY]}"
GCP_REGION="${2:-europe-west1}"
NAMESPACE="${3:-blaze}"
CLIENT_KEY="${4:-b9}"
GITHUB_ORG="${GITHUB_ORG:-thebyte9}"
GITHUB_REPO="${GITHUB_REPO:-blaze-template-deploy}"
ACTIONS_ORG="${ACTIONS_ORG:-thisisblaze}"
ACTIONS_REPO="${ACTIONS_REPO:-blaze-actions}"

# All repos that need GCP secrets (org/repo pairs)
GCP_SECRET_REPOS=(
  "$GITHUB_ORG/$GITHUB_REPO"
  "$ACTIONS_ORG/$ACTIONS_REPO"
)

# ── Derived ──
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/../infra/live" && pwd)"
GCS_TFSTATE_DIR="$INFRA_DIR/common/gcs-tfstate"
GITHUB_WIF_DIR="$INFRA_DIR/common/github-wif"
STATE_BUCKET="${NAMESPACE}-${CLIENT_KEY}-tfstate"

echo "═══════════════════════════════════════════════════════"
echo "  🚀 GCP Bootstrap"
echo "═══════════════════════════════════════════════════════"
echo "  Project:     $GCP_PROJECT_ID"
echo "  Region:      $GCP_REGION"
echo "  Namespace:   $NAMESPACE"
echo "  Client:      $CLIENT_KEY"
echo "  State Bucket: $STATE_BUCKET"
echo "  GitHub:      ${GCP_SECRET_REPOS[*]}"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── Pre-flight ──
echo "🔍 Pre-flight checks..."
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud not found"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ terraform not found"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "❌ gh CLI not found"; exit 1; }

# Verify project access
gcloud projects describe "$GCP_PROJECT_ID" >/dev/null 2>&1 || {
  echo "❌ Cannot access project: $GCP_PROJECT_ID"
  echo "   Run: gcloud auth login && gcloud config set project $GCP_PROJECT_ID"
  exit 1
}

# Enable required APIs
echo ""
echo "📡 Enabling required GCP APIs..."
APIS=(
  "iam.googleapis.com"
  "iamcredentials.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "run.googleapis.com"
  "artifactregistry.googleapis.com"
  "storage.googleapis.com"
  "sts.googleapis.com"
)
for api in "${APIS[@]}"; do
  echo "   Enabling: $api"
  gcloud services enable "$api" --project="$GCP_PROJECT_ID" --quiet 2>/dev/null || true
done
echo "✅ APIs enabled."

# ═══════════════════════════════════════════════════════
# Step 1: GCS Terraform State Bucket
# ═══════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  📦 Step 1/3: GCS Terraform State Bucket"
echo "═══════════════════════════════════════════════════════"

cd "$GCS_TFSTATE_DIR"

# Create tfvars
cat > terraform.tfvars <<EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
namespace      = "$NAMESPACE"
client_key     = "$CLIENT_KEY"
EOF

echo "   Created terraform.tfvars"

# Init with local backend (bootstrap)
terraform init -input=false
terraform plan -out=tfplan
echo ""
echo "   🟡 Review the plan above."
read -rp "   Apply? (yes/no): " CONFIRM
if [[ "$CONFIRM" == "yes" ]]; then
  terraform apply tfplan
  echo "   ✅ GCS state bucket created: $STATE_BUCKET"
else
  echo "   ⏭️ Skipped."
fi
rm -f tfplan

# ═══════════════════════════════════════════════════════
# Step 2: GitHub Workload Identity Federation
# ═══════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🔐 Step 2/3: Workload Identity Federation"
echo "═══════════════════════════════════════════════════════"

cd "$GITHUB_WIF_DIR"

# Create tfvars
cat > terraform.tfvars <<EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
namespace      = "$NAMESPACE"
client_key     = "$CLIENT_KEY"
github_orgs    = ["$GITHUB_ORG", "$ACTIONS_ORG"]
github_repos   = ["$GITHUB_ORG/$GITHUB_REPO", "$ACTIONS_ORG/$ACTIONS_REPO"]
EOF

echo "   Created terraform.tfvars"

# Init with GCS backend (bucket now exists)
terraform init -input=false \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="prefix=infra/common/github-wif"

terraform plan -out=tfplan
echo ""
echo "   🟡 Review the plan above."
read -rp "   Apply? (yes/no): " CONFIRM
if [[ "$CONFIRM" == "yes" ]]; then
  terraform apply tfplan

  # Extract outputs
  WIF_PROVIDER=$(terraform output -raw workload_identity_provider)
  SA_EMAIL=$(terraform output -raw service_account_email)

  echo ""
  echo "   ✅ Workload Identity Federation created!"
  echo "   📋 WIF Provider: $WIF_PROVIDER"
  echo "   📋 SA Email:     $SA_EMAIL"
else
  echo "   ⏭️ Skipped."
  WIF_PROVIDER=""
  SA_EMAIL=""
fi
rm -f tfplan

# ═══════════════════════════════════════════════════════
# Step 3: Set GitHub Secrets
# ═══════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🔑 Step 3/3: GitHub Secrets"
echo "═══════════════════════════════════════════════════════"

if [[ -n "$WIF_PROVIDER" && -n "$SA_EMAIL" ]]; then
  echo "   Setting secrets on ${#GCP_SECRET_REPOS[@]} repos..."

  for repo in "${GCP_SECRET_REPOS[@]}"; do
    echo "   → $repo"
    gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER \
      --repo="$repo" \
      --body="$WIF_PROVIDER"
    gh secret set GCP_SERVICE_ACCOUNT \
      --repo="$repo" \
      --body="$SA_EMAIL"
  done

  echo ""
  echo "   ✅ GitHub secrets set on: ${GCP_SECRET_REPOS[*]}"
else
  echo "   ⚠️ WIF outputs not available. Set these secrets manually:"
  echo ""
  for repo in "${GCP_SECRET_REPOS[@]}"; do
    echo "   gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --repo=$repo --body='<WIF_PROVIDER>'"
    echo "   gh secret set GCP_SERVICE_ACCOUNT --repo=$repo --body='<SA_EMAIL>'"
  done
fi

# ═══════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✅ Bootstrap Complete!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "  1. Update vars/blaze-env.json with real GCP_PROJECT_ID: $GCP_PROJECT_ID"
echo "  2. Update vars/blaze-env.json with real GCP_STATE_BUCKET: $STATE_BUCKET"
echo "  3. Trigger 01-provision-infra (cloud_provider=gcp, stack=network)"
echo "  4. Trigger 02-deploy-app (cloud_provider=gcp)"
echo ""
echo "  🌐 GCP Console: https://console.cloud.google.com/home/dashboard?project=$GCP_PROJECT_ID"
echo "  📦 State Bucket: https://console.cloud.google.com/storage/browser/$STATE_BUCKET?project=$GCP_PROJECT_ID"
echo ""
