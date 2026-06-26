#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Plan 176 — Pre-Apply Orphan Detection: MongoDB Atlas
# ---------------------------------------------------------------------------
# Runs in the third-party/mongodb tf_dir AFTER `terraform init`, BEFORE plan/apply
# (invoked by reusable-terraform.yml -> "Run Pre-Apply Script" via the local
#  pre_apply.sh hook in 01-provision-infra.yml).
#
# Purpose: if a workflow cancellation killed Terraform before it could push
# state to S3, the Atlas cluster exists in the cloud but not in state. On the
# next run Terraform would CREATE a duplicate. This hook detects that case and
# `terraform import`s the existing cluster so apply reconciles instead.
#
# Policy (Plan 176): import on exact NAME match regardless of cluster health
# (a mid-provisioning cluster still counts — reconcile, never duplicate).
#
# Idempotent + non-fatal: any failure is logged and swallowed so a transient
# API hiccup can never block a legitimate apply.
#
# OBSERVABILITY: every exit path emits a single, greppable outcome line
#   PRE_APPLY_RESULT[mongodb]=<TOKEN>
# plus a GitHub ::notice:: and a run-summary row, so the Plan 176 smoke test can
# assert the outcome unambiguously. Tokens:
#   SKIPPED_DESTROY | SKIPPED_NO_CONFIG | SKIPPED_NO_PROJECT | SKIPPED_NO_CREDS
#   ALREADY_IN_STATE | NO_ORPHAN | IMPORTED | IMPORT_FAILED
# ---------------------------------------------------------------------------
set -uo pipefail

COMPONENT="mongodb"

# emit_result <TOKEN> <human message> — single source of truth for the outcome.
emit_result() {
  local token="$1" msg="$2"
  echo "────────────────────────────────────────────────────────────"
  echo "PRE_APPLY_RESULT[${COMPONENT}]=${token}"
  echo "🔖 [pre_apply ${COMPONENT}] ${msg}"
  echo "::notice title=pre_apply ${COMPONENT}::${token} — ${msg}"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### 🍃 Pre-Apply (third-party-${COMPONENT})"
      echo "| Result | Detail |"
      echo "| :--- | :--- |"
      echo "| \`${token}\` | ${msg} |"
    } >> "$GITHUB_STEP_SUMMARY"
  fi
  echo "────────────────────────────────────────────────────────────"
}

# Destroy runs must never import — let teardown proceed untouched.
if [[ "${TF_DESTROY:-false}" == "true" ]]; then
  emit_result "SKIPPED_DESTROY" "Destroy run — orphan import not applicable."
  exit 0
fi

NAMESPACE="${TF_VAR_namespace:-blaze}"
CLIENT_KEY="${TF_VAR_client_key:-}"
PLATFORM="${TF_VAR_platform:-ecs}"
STAGE="${TF_VAR_stage:-}"
CLUSTER_TIER="${TF_VAR_cluster_tier:-auto}"
PROJECT_ID="${TF_VAR_atlas_project_id:-${MONGODB_ATLAS_PROJECT_ID:-}}"
PUB="${MONGODB_ATLAS_PUBLIC_KEY:-}"
PRIV="${MONGODB_ATLAS_PRIVATE_KEY:-}"

# Naming MUST match the module: <namespace>-<client>-<platform>-<stage>
# (blaze-terraform-infra-core/modules/mongodbatlas/cluster local.cluster_name)
CLUSTER_NAME="${NAMESPACE}-${CLIENT_KEY}-${PLATFORM}-${STAGE}"

# Flex detection mirrors the module: lower(cluster_tier) == "flex"
shopt -s nocasematch
if [[ "$CLUSTER_TIER" == "flex" ]]; then
  TF_ADDR='module.mongodb_cluster.mongodbatlas_flex_cluster.flex[0]'
  IS_FLEX="true"
else
  TF_ADDR='module.mongodb_cluster.mongodbatlas_advanced_cluster.main[0]'
  IS_FLEX="false"
fi
shopt -u nocasematch

echo "🔎 [pre_apply ${COMPONENT}] Orphan check — cluster='${CLUSTER_NAME}' tier='${CLUSTER_TIER}' flex=${IS_FLEX} addr='${TF_ADDR}'"

if [[ -z "$CLIENT_KEY" || -z "$STAGE" ]]; then
  emit_result "SKIPPED_NO_CONFIG" "Missing client_key/stage — cannot compute cluster name."
  exit 0
fi
if [[ -z "$PROJECT_ID" ]]; then
  emit_result "SKIPPED_NO_PROJECT" "No Atlas project id — TF will create the project; nothing to import."
  exit 0
fi
if [[ -z "$PUB" || -z "$PRIV" ]]; then
  emit_result "SKIPPED_NO_CREDS" "Atlas API keys not present — cannot probe Atlas."
  exit 0
fi

# Already tracked? Then there is nothing to recover.
if terraform state list 2>/dev/null | grep -qF "$TF_ADDR"; then
  emit_result "ALREADY_IN_STATE" "Cluster already tracked in Terraform state — no import needed."
  exit 0
fi

# ── API existence probe (digest auth, mirrors post_provision usage) ──────────
ATLAS_BASE="https://cloud.mongodb.com/api/atlas"
EXISTS="false"
if [[ "$IS_FLEX" == "true" ]]; then
  # Flex clusters live under the v2 versioned endpoint.
  HTTP=$(curl -s -o /tmp/atlas_probe.json -w "%{http_code}" --digest -u "${PUB}:${PRIV}" \
    -H "Accept: application/vnd.atlas.2024-11-13+json" \
    "${ATLAS_BASE}/v2/groups/${PROJECT_ID}/flexClusters/${CLUSTER_NAME}" || echo "000")
else
  HTTP=$(curl -s -o /tmp/atlas_probe.json -w "%{http_code}" --digest -u "${PUB}:${PRIV}" \
    "${ATLAS_BASE}/v1.0/groups/${PROJECT_ID}/clusters/${CLUSTER_NAME}" || echo "000")
fi

if [[ "$HTTP" == "200" ]]; then
  EXISTS="true"
elif [[ "$HTTP" == "404" ]]; then
  EXISTS="false"
else
  echo "⚠️  [pre_apply ${COMPONENT}] API probe inconclusive (HTTP ${HTTP}). Attempting import defensively."
  EXISTS="true"  # fail-safe: prefer import attempt over risking a duplicate
fi

if [[ "$EXISTS" != "true" ]]; then
  emit_result "NO_ORPHAN" "No orphaned cluster named '${CLUSTER_NAME}' in Atlas (HTTP ${HTTP}) — apply will create cleanly."
  exit 0
fi

# ── Import (id format: <project_id>-<cluster_name>) ──────────────────────────
IMPORT_ID="${PROJECT_ID}-${CLUSTER_NAME}"
echo "📥 [pre_apply ${COMPONENT}] Orphan detected (probe HTTP ${HTTP}) — importing ${TF_ADDR} <- ${IMPORT_ID}"
if terraform import "$TF_ADDR" "$IMPORT_ID"; then
  emit_result "IMPORTED" "Adopted orphaned cluster '${CLUSTER_NAME}' (id=${IMPORT_ID}) into state — duplicate prevented."
else
  emit_result "IMPORT_FAILED" "terraform import of '${CLUSTER_NAME}' (id=${IMPORT_ID}) failed — apply not blocked; inspect logs."
fi

exit 0
