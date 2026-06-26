#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Plan 176 — Pre-Apply Orphan Detection: Elastic Cloud
# ---------------------------------------------------------------------------
# Runs in the third-party/elastic tf_dir AFTER `terraform init`, BEFORE plan/apply
# (invoked by reusable-terraform.yml -> "Run Pre-Apply Script" via the local
#  pre_apply.sh hook in 01-provision-infra.yml).
#
# Purpose: if a workflow cancellation killed Terraform before it could push
# state to S3, the Elastic deployment exists in the cloud but not in state.
# On the next run Terraform would CREATE a duplicate (the multiple
# `blaze-b9-ecs-dev` deployments seen in Plan 176). This hook detects that and
# `terraform import`s the existing deployment so apply reconciles instead.
#
# Policy (Plan 176): import on exact NAME match regardless of deployment health.
#
# Idempotent + non-fatal: any failure is logged and swallowed.
# ---------------------------------------------------------------------------
set -uo pipefail

if [[ "${TF_DESTROY:-false}" == "true" ]]; then
  echo "🟦 [pre_apply elastic] Destroy run — skipping orphan import."
  exit 0
fi

NAMESPACE="${TF_VAR_namespace:-blaze}"
CLIENT_KEY="${TF_VAR_client_key:-}"
PLATFORM="${TF_VAR_platform:-ecs}"
STAGE="${TF_VAR_stage:-}"
EC_KEY="${EC_API_KEY:-}"

# Naming MUST match the module: <namespace>-<client>-<platform>-<stage>
# (blaze-terraform-infra-core/modules/third-party/elastic-deployment local.deployment_name)
DEPLOYMENT_NAME="${NAMESPACE}-${CLIENT_KEY}-${PLATFORM}-${STAGE}"
TF_ADDR='module.elastic_deployment.ec_deployment.main'

echo "🔎 [pre_apply elastic] Orphan check — deployment='${DEPLOYMENT_NAME}'"

if [[ -z "$CLIENT_KEY" || -z "$STAGE" ]]; then
  echo "⚠️  [pre_apply elastic] Missing client_key/stage — cannot compute deployment name. Skipping."
  exit 0
fi
if [[ -z "$EC_KEY" ]]; then
  echo "⚠️  [pre_apply elastic] EC_API_KEY not present. Skipping import."
  exit 0
fi

if terraform state list 2>/dev/null | grep -qF "$TF_ADDR"; then
  echo "✅ [pre_apply elastic] Deployment already in Terraform state. No import needed."
  exit 0
fi

# ── API existence probe: search deployments by exact name ────────────────────
EC_BASE="https://api.elastic-cloud.com/api/v1"
SEARCH_BODY=$(cat <<JSON
{ "query": { "bool": { "must": [ { "term": { "name": { "value": "${DEPLOYMENT_NAME}" } } } ] } } }
JSON
)

HTTP=$(curl -s -o /tmp/ec_probe.json -w "%{http_code}" \
  -H "Authorization: ApiKey ${EC_KEY}" \
  -H "Content-Type: application/json" \
  -X POST "${EC_BASE}/deployments/_search" \
  -d "$SEARCH_BODY" || echo "000")

DEPLOYMENT_ID=""
if [[ "$HTTP" == "200" ]]; then
  # Prefer an exact name match; fall back to the first hit if the term query is loose.
  DEPLOYMENT_ID=$(jq -r --arg n "$DEPLOYMENT_NAME" \
    'first(.deployments[]? | select(.name == $n) | .id) // (.deployments[0].id // empty)' \
    /tmp/ec_probe.json 2>/dev/null || echo "")
else
  echo "⚠️  [pre_apply elastic] Search API inconclusive (HTTP ${HTTP}). Cannot resolve id — skipping import."
  exit 0
fi

if [[ -z "$DEPLOYMENT_ID" || "$DEPLOYMENT_ID" == "null" ]]; then
  echo "✅ [pre_apply elastic] No orphaned deployment in Elastic Cloud. Apply will create cleanly."
  exit 0
fi

# ── Import (id = Elastic Cloud deployment id) ────────────────────────────────
echo "📥 [pre_apply elastic] Orphan detected — importing ${TF_ADDR} <- ${DEPLOYMENT_ID}"
if terraform import "$TF_ADDR" "$DEPLOYMENT_ID"; then
  echo "✅ [pre_apply elastic] Imported orphaned deployment into state. Duplicate prevented."
else
  echo "⚠️  [pre_apply elastic] Import failed (will not block apply). Inspect run logs."
fi

exit 0
