#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Plan 176 — Cleanup Utility: Orphaned Third-Party Data Stacks
# ---------------------------------------------------------------------------
# Reconciles live MongoDB Atlas clusters and Elastic Cloud deployments against
# the Terraform state stored in S3. Any live cluster that:
#   (a) matches this tenant's naming prefix  <namespace>-<client_key>-  AND
#   (b) does NOT appear in any third-party-*.tfstate file in the state bucket
# is considered ORPHANED (left behind by a cancelled provision that never
# pushed state) and is terminated.
#
# SAFETY:
#   - Scoped to <namespace>-<client_key>- prefix so it can never touch clusters
#     belonging to other tenants sharing the same Atlas org / EC account.
#   - DRY_RUN=true (default) only reports; it never deletes.
#   - Destructive deletes require DRY_RUN=false (the workflow additionally gates
#     this behind a typed DESTROY-<env>-<stack> confirmation).
#
# Required env:
#   BUCKET, PROJECT_KEY, NAMESPACE, CLIENT_KEY, AWS_REGION
#   MONGODB_ATLAS_PUBLIC_KEY, MONGODB_ATLAS_PRIVATE_KEY, MONGODB_ATLAS_PROJECT_ID
#   EC_API_KEY
#   DRY_RUN ("true" | "false")
# Optional env:
#   STAGE — when set, scope is restricted to clusters for that stage only.
#     CRITICAL: the state bucket is per-stage (<client>-<stage>-<ns>-tfstate), so a
#     sweep only sees ONE stage's state, while the Atlas/EC live lists are global.
#     Without a stage bound, a dev sweep would wrongly flag stage/prod clusters
#     (same <ns>-<client>- prefix) as orphans. Cluster names end with -<stage>.
#   SLACK_WEBHOOK_URL — when set, posts an alert if orphans are found.
# ---------------------------------------------------------------------------
set -uo pipefail

DRY_RUN="${DRY_RUN:-true}"
SCOPE_PREFIX="${NAMESPACE:-blaze}-${CLIENT_KEY:-}-"
STAGE="${STAGE:-}"
ATLAS_BASE="https://cloud.mongodb.com/api/atlas"
EC_BASE="https://api.elastic-cloud.com/api/v1"
PROJECT_ID="${MONGODB_ATLAS_PROJECT_ID:-}"
PUB="${MONGODB_ATLAS_PUBLIC_KEY:-}"
PRIV="${MONGODB_ATLAS_PRIVATE_KEY:-}"
EC_KEY="${EC_API_KEY:-}"

ORPHANS_FOUND=0
ORPHANS_DELETED=0

echo "🧹 Orphan cleanup — scope prefix='${SCOPE_PREFIX}' | dry_run=${DRY_RUN}"
if [[ -z "${CLIENT_KEY:-}" ]]; then
  echo "❌ CLIENT_KEY empty — refusing to run unscoped (would risk other tenants). Aborting."
  exit 1
fi

# ── 1. Build the TRACKED sets from S3 state ──────────────────────────────────
# Scan the ENTIRE bucket (all projects), not just this PROJECT_KEY: the Atlas/
# Elastic cluster name (<namespace>-<client>-<platform>-<stage>) does NOT include
# the project key, while the orphan scope prefix spans all of a client's projects.
# Scanning only one project would wrongly flag another project's live cluster as
# an orphan. Scanning all state files means any resource tracked anywhere is safe.
#
# Two sets, because the two providers need different identity keys:
#   - TRACKED_NAMES — Atlas cluster names. Atlas forbids duplicate names within a
#     project, so name is a safe unique key.
#   - TRACKED_IDS — Elastic deployment IDs. Elastic Cloud ALLOWS multiple
#     deployments with the SAME name (this is exactly how the orphan duplicates in
#     Plan 176 piled up), so name is NOT unique — we must reconcile by id.
TRACKED_NAMES="$(mktemp)"
TRACKED_IDS="$(mktemp)"
echo "📖 Scanning S3 state across all projects: s3://${BUCKET}/infra/ ..."
STATE_KEYS=$(aws s3 ls "s3://${BUCKET}/infra/" --recursive 2>/dev/null \
  | awk '{print $4}' | grep -E 'third-party-(mongodb|elastic)\.tfstate$' || true)

if [[ -n "$STATE_KEYS" ]]; then
  STATE_DIR="$(mktemp -d)"
  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    aws s3 cp "s3://${BUCKET}/${key}" "${STATE_DIR}/$(echo "$key" | tr '/' '_')" 2>/dev/null || true
  done <<< "$STATE_KEYS"

  # Atlas: track by name
  cat "${STATE_DIR}"/* 2>/dev/null | jq -r '.resources[]?
      | select(.type=="mongodbatlas_advanced_cluster" or .type=="mongodbatlas_flex_cluster")
      | .instances[]?.attributes.name // empty' 2>/dev/null | sort -u > "$TRACKED_NAMES"
  # Elastic: track by deployment id (name is not unique)
  cat "${STATE_DIR}"/* 2>/dev/null | jq -r '.resources[]?
      | select(.type=="ec_deployment")
      | .instances[]?.attributes.id // empty' 2>/dev/null | sort -u > "$TRACKED_IDS"
  rm -rf "$STATE_DIR"
fi
echo "   Tracked Atlas names: $(wc -l < "$TRACKED_NAMES" | tr -d ' ') | Tracked Elastic ids: $(wc -l < "$TRACKED_IDS" | tr -d ' ')"

name_tracked() { grep -qxF "$1" "$TRACKED_NAMES"; }
id_tracked()   { grep -qxF "$1" "$TRACKED_IDS"; }
# In scope = matches tenant prefix AND (if STAGE set) ends with -<stage>.
# The suffix guard keeps a per-stage sweep from touching another stage's clusters.
in_scope() {
  [[ "$1" == "${SCOPE_PREFIX}"* ]] || return 1
  [[ -z "$STAGE" || "$1" == *"-${STAGE}" ]]
}
echo "   Scope: prefix='${SCOPE_PREFIX}'${STAGE:+ , stage-suffix='-${STAGE}'}"

# ── 2. MongoDB Atlas: list live clusters (standard + flex) ───────────────────
if [[ -n "$PROJECT_ID" && -n "$PUB" && -n "$PRIV" ]]; then
  echo "🍃 Checking MongoDB Atlas project ${PROJECT_ID}..."

  STD=$(curl -s --digest -u "${PUB}:${PRIV}" \
    "${ATLAS_BASE}/v1.0/groups/${PROJECT_ID}/clusters" 2>/dev/null \
    | jq -r '.results[]?.name // empty' 2>/dev/null || true)
  FLEX=$(curl -s --digest -u "${PUB}:${PRIV}" \
    -H "Accept: application/vnd.atlas.2024-11-13+json" \
    "${ATLAS_BASE}/v2/groups/${PROJECT_ID}/flexClusters" 2>/dev/null \
    | jq -r '.results[]?.name // empty' 2>/dev/null || true)

  for name in $STD; do
    in_scope "$name" || continue
    if name_tracked "$name"; then
      echo "   ✅ tracked: $name"
    else
      ORPHANS_FOUND=$((ORPHANS_FOUND+1))
      echo "   🚨 ORPHAN (standard cluster): $name"
      if [[ "$DRY_RUN" != "true" ]]; then
        CODE=$(curl -s -o /dev/null -w "%{http_code}" --digest -u "${PUB}:${PRIV}" \
          -X DELETE "${ATLAS_BASE}/v1.0/groups/${PROJECT_ID}/clusters/${name}" || echo "000")
        if [[ "$CODE" =~ ^20[0-9]$ ]]; then
          echo "      🗑️  Termination requested (HTTP ${CODE})"; ORPHANS_DELETED=$((ORPHANS_DELETED+1))
        else
          echo "      ⚠️  Delete failed (HTTP ${CODE})"
        fi
      fi
    fi
  done

  for name in $FLEX; do
    in_scope "$name" || continue
    if name_tracked "$name"; then
      echo "   ✅ tracked (flex): $name"
    else
      ORPHANS_FOUND=$((ORPHANS_FOUND+1))
      echo "   🚨 ORPHAN (flex cluster): $name"
      if [[ "$DRY_RUN" != "true" ]]; then
        CODE=$(curl -s -o /dev/null -w "%{http_code}" --digest -u "${PUB}:${PRIV}" \
          -H "Accept: application/vnd.atlas.2024-11-13+json" \
          -X DELETE "${ATLAS_BASE}/v2/groups/${PROJECT_ID}/flexClusters/${name}" || echo "000")
        if [[ "$CODE" =~ ^20[0-9]$ ]]; then
          echo "      🗑️  Termination requested (HTTP ${CODE})"; ORPHANS_DELETED=$((ORPHANS_DELETED+1))
        else
          echo "      ⚠️  Delete failed (HTTP ${CODE})"
        fi
      fi
    fi
  done
else
  echo "ℹ️  Atlas credentials/project missing — skipping MongoDB scan."
fi

# ── 3. Elastic Cloud: list live deployments ──────────────────────────────────
if [[ -n "$EC_KEY" ]]; then
  echo "🔍 Checking Elastic Cloud deployments..."
  EC_JSON=$(curl -s -H "Authorization: ApiKey ${EC_KEY}" -H "Content-Type: application/json" \
    -X POST "${EC_BASE}/deployments/_search" \
    -d '{"query":{"match_all":{}},"size":500}' 2>/dev/null || echo '{}')

  while IFS=$'\t' read -r dep_id dep_name; do
    [[ -z "$dep_name" || -z "$dep_id" ]] && continue
    in_scope "$dep_name" || continue
    # Reconcile by ID: a duplicate orphan shares the name of the tracked one,
    # so name-matching would hide it. Only the deployment whose ID is in state
    # is legitimate; every other in-scope deployment is an orphan.
    if id_tracked "$dep_id"; then
      echo "   ✅ tracked: $dep_name ($dep_id)"
    else
      ORPHANS_FOUND=$((ORPHANS_FOUND+1))
      echo "   🚨 ORPHAN (elastic deployment): $dep_name ($dep_id)"
      if [[ "$DRY_RUN" != "true" ]]; then
        CODE=$(curl -s -o /dev/null -w "%{http_code}" \
          -H "Authorization: ApiKey ${EC_KEY}" \
          -X POST "${EC_BASE}/deployments/${dep_id}/_shutdown" || echo "000")
        if [[ "$CODE" =~ ^20[0-9]$ ]]; then
          echo "      🗑️  Shutdown requested (HTTP ${CODE})"; ORPHANS_DELETED=$((ORPHANS_DELETED+1))
        else
          echo "      ⚠️  Shutdown failed (HTTP ${CODE})"
        fi
      fi
    fi
  done < <(echo "$EC_JSON" | jq -r '.deployments[]? | [.id, .name] | @tsv' 2>/dev/null)
else
  echo "ℹ️  EC_API_KEY missing — skipping Elastic scan."
fi

rm -f "$TRACKED_NAMES" "$TRACKED_IDS"

# ── 4. Summary ────────────────────────────────────────────────────────────────
MODE=$([[ "$DRY_RUN" == "true" ]] && echo "DRY-RUN" || echo "LIVE")
echo "----------------------------------------------------------------"
echo "📊 Orphans found: ${ORPHANS_FOUND} | Terminated: ${ORPHANS_DELETED} | Mode: ${MODE}"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## 🧹 Orphaned Data Stack Cleanup"
    echo "| Metric | Value |"
    echo "| :--- | :--- |"
    echo "| **Scope** | \`${SCOPE_PREFIX}*\` |"
    echo "| **Mode** | $([[ "$DRY_RUN" == "true" ]] && echo '🔵 Dry Run' || echo '🟢 Live') |"
    echo "| **Orphans found** | ${ORPHANS_FOUND} |"
    echo "| **Terminated** | ${ORPHANS_DELETED} |"
  } >> "$GITHUB_STEP_SUMMARY"
fi

# ── 5. Slack alert (optional) — only when orphans were found ─────────────────
if [[ ${ORPHANS_FOUND} -gt 0 && -n "${SLACK_WEBHOOK_URL:-}" ]]; then
  RUN_LINK="${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"
  curl -s -X POST -H 'Content-type: application/json' --data \
    "{\"text\":\"🧹 *Orphaned data stacks detected* (${MODE})\\n*Scope*: \`${SCOPE_PREFIX}*\`\\n*Found*: ${ORPHANS_FOUND} | *Terminated*: ${ORPHANS_DELETED}\\n<${RUN_LINK}|View run>\"}" \
    "${SLACK_WEBHOOK_URL}" >/dev/null 2>&1 || echo "⚠️  Slack notification failed (non-fatal)."
fi

# Surface a visible note in dry-run if orphans exist (does not fail the run)
if [[ "$DRY_RUN" == "true" && $ORPHANS_FOUND -gt 0 ]]; then
  echo "⚠️  Orphans detected (dry-run). Re-run with dry_run=false to terminate."
fi
exit 0
