---
description: Run a best-practice audit by cross-referencing current CI/CD workflows against the curated reference source library
expected_output: A gap analysis report in docs/reports/YYYY-MM-DD-best-practice-audit.md
exclusions: Read-only. Do NOT modify workflows or infrastructure during this audit. Report findings only.
---

# 12 — Best Practice Audit

> [!TIP]
> **Status: SCALED (ECS Fargate Environment)**. Audit scope: blaze-actions GitHub Actions reusable workflows + multi-cloud CI/CD.

**Source Library**: [`docs/learning/REFERENCE_SOURCE_LIBRARY.md`](docs/learning/REFERENCE_SOURCE_LIBRARY.md)

---

## Step 1 — Load the Reference Library

```bash
cat ~/Workspace/thisisblaze/blaze-actions/docs/learning/REFERENCE_SOURCE_LIBRARY.md
```

---

## Step 2 — Gather Current State

```bash
# All reusable workflows
ls .github/workflows/reusable-*.yml
# All wrapper workflows
ls .github/workflows/[0-9]*.yml
# Check-access action
cat .github/actions/check-access/action.yml
# Actionlint CI gate
cat .github/workflows/05_ci_no_cloud.yml
```

Use `mcp_github-mcp-server_search_code` to compare against reference repos:
```
query: "workflow_call secrets inherit repo:actions/checkout"
query: "permissions id-token write repo:aws-actions/configure-aws-credentials"
```

---

## Step 3 — Priority Checks

| # | Check | How to verify |
|---|---|---|
| P1 | OIDC role — env-scoped trust (not `repo:*`) | `grep -rn "condition\|sub\|StringLike" .github/aws/infra/` |
| P2 | Actionlint covers ALL workflows | `cat .github/workflows/05_ci_no_cloud.yml \| grep -A5 actionlint` |
| P3 | SHA/stable pins on external actions | `grep -rn "uses:.*actions/" .github/workflows/ \| grep -v "thisisblaze\|v[0-9]"` |
| P4 | Every Terraform workflow has `concurrency:` | `for f in .github/workflows/*terraform*.yml; do grep -L "concurrency" $f; done` |
| P5 | `secrets: inherit` or explicit in `workflow_call` | `grep -rn "secrets:" .github/workflows/reusable-*.yml \| head -20` |
| P6 | `timeout-minutes` on all jobs | `grep -rL "timeout-minutes" .github/workflows/*.yml` |
| P7 | `check-access` gates all destructive workflows | `grep -L "check-access" .github/workflows/*destroy*.yml .github/workflows/*nuke*.yml` |
| P8 | Pre-destroy ECS scale-to-0 | `grep -n "desiredCount\|scale.*0\|desired_count" .github/workflows/reusable-pre-destroy-cleanup.yml` |
| P9 | `known fixes` still applicable | Read `docs/knowledge/*.md` — check if any fix has become obsolete |

---

## Step 4 — Knowledge Base Freshness Check

For each file in `docs/knowledge/`:
- Is the described issue still a real concern given current provider/action versions?
- Is the documented fix still the correct approach?
- Flag any that need updating.

```bash
ls docs/knowledge/*.md
# Check dates and current provider versions
grep "Last Updated\|provider\|version" docs/knowledge/*.md
```

---

## Step 5 — Write Report

```
docs/reports/YYYY-MM-DD-best-practice-audit.md
```

Structure:
```markdown
# Best Practice Audit — YYYY-MM-DD
**Scope**: blaze-actions reusable workflows | **Library**: docs/learning/REFERENCE_SOURCE_LIBRARY.md

## Summary
X checks. Y aligned ✅. Z gaps (A critical 🔴, B warnings ⚠️).

## Findings
### ✅ Aligned
### ⚠️ Partial
### 🔴 Gap (Action Required)

## Knowledge Base Freshness
- Still valid: ...
- Needs update: ...

## Next Audit Due: YYYY-MM-DD
```

**Do NOT apply fixes** — report only. Flag 🔴 gaps for `/01-add-workflow` or manual remediation.
