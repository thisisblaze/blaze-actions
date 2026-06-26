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
#
# OBSERVABILITY: every exit path emits a single, greppable outcome line
#   PRE_APPLY_RESULT[elastic]=<TOKEN>
# plus a GitHub ::notice:: and a run-summary row, so the Plan 176 smoke test can
# assert the outcome unambiguously. Tokens:
#   SKIPPED_DESTROY | SKIPPED_NO_CONFIG | SKIPPED_NO_CREDS | ALREADY_IN_STATE
#   SKIPPED_API_ERROR | NO_ORPHAN | IMPORTED | IMPORT_FAILED
# ---------------------------------------------------------------------------
set -uo pipefail

COMPONENT="elastic"

# emit_result <TOKEN> <human message> — single source of truth for the outcome.
emit_result() {
  local token="$1" msg="$2"
  echo "────────────────────────────────────────────────────────────"
  echo "PRE_APPLY_RESULT[${COMPONENT}]=${token}"
  echo "🔖 [pre_apply ${COMPONENT}] ${msg}"
  echo "::notice title=pre_apply ${COMPONENT}::${token} — ${msg}"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### 🔌 Pre-Apply (third-party-${COMPONENT})"
      echo "| Result | Detail |"
      echo "| :--- | :--- |"
      echo "| \`${token}\` | ${msg} |"
    } >> "$GITHUB_STEP_SUMMARY"
  fi
  echo "────────────────────────────────────────────────────────────"
}

if [[ "${TF_DESTROY:-false}" == "true" ]]; then
  emit_result "SKIPPED_DESTROY" "Destroy run — orphan import not applicable."
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

echo "🔎 [pre_apply ${COMPONENT}] Orphan check — deployment='${DEPLOYMENT_NAME}' addr='${TF_ADDR}'"

if [[ -z "$CLIENT_KEY" || -z "$STAGE" ]]; then
  emit_result "SKIPPED_NO_CONFIG" "Missing client_key/stage — cannot compute deployment name."
  exit 0
fi
if [[ -z "$EC_KEY" ]]; then
  emit_result "SKIPPED_NO_CREDS" "EC_API_KEY not present — cannot probe Elastic Cloud."
  exit 0
fi

if terraform state list 2>/dev/null | grep -qF "$TF_ADDR"; then
  emit_result "ALREADY_IN_STATE" "Deployment already tracked in Terraform state — no import needed."
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
  emit_result "SKIPPED_API_ERROR" "Elastic _search inconclusive (HTTP ${HTTP}) — cannot resolve id."
  exit 0
fi

if [[ -z "$DEPLOYMENT_ID" || "$DEPLOYMENT_ID" == "null" ]]; then
  emit_result "NO_ORPHAN" "No orphaned deployment named '${DEPLOYMENT_NAME}' in Elastic Cloud — apply will create cleanly."
  exit 0
fi

# ── Import (id = Elastic Cloud deployment id) ────────────────────────────────
echo "📥 [pre_apply ${COMPONENT}] Orphan detected — importing ${TF_ADDR} <- ${DEPLOYMENT_ID}"
if terraform import "$TF_ADDR" "$DEPLOYMENT_ID"; then
  emit_result "IMPORTED" "Adopted orphaned deployment '${DEPLOYMENT_NAME}' (id=${DEPLOYMENT_ID}) into state — duplicate prevented."
else
  emit_result "IMPORT_FAILED" "terraform import of '${DEPLOYMENT_NAME}' (id=${DEPLOYMENT_ID}) failed — apply not blocked; inspect logs."
fi

exit 0
