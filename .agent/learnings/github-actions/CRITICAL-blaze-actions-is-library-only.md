# 🚨 CRITICAL: blaze-actions is a LIBRARY — Never Run Workflows From It

**Category:** architecture | **Severity:** CRITICAL | **Recurrence:** REPEATED MULTIPLE TIMES

---

## Problem / Error

The AI agent repeatedly made the mistake of:
1. Running workflow dispatches from `thisisblaze/blaze-actions`
2. Attempting to debug secrets (GH_PAT, GCP_*, etc.) on `blaze-actions`
3. Triggering stress tests (`stress-test-gcp.yml`) from `blaze-actions`
4. Looking for secrets that don't exist on `blaze-actions`

This has happened multiple times across multiple sessions.

---

## Root Cause

Confusion about the repo architecture. The agent treated `blaze-actions` like a deployment repo, but it is a **pure reusable workflow library**.

---

## The Correct Architecture

```
blaze-actions (LIBRARY - thisisblaze/blaze-actions)
    └── Defines:  reusable workflows, composite actions, calculate-config logic
    └── NO secrets, NO direct runs, NO deployments

blaze-template-deploy (DEPLOYMENT REPO - thebyte9/blaze-template-deploy)
    └── Consumes:  blaze-actions workflows via `uses: thisisblaze/blaze-actions/...@dev`
    └── HAS:       all secrets (GH_PAT, AWS_ROLE_ARN, GCP_*, CLOUDFLARE_*, etc.)
    └── RUNS:      ALL stress tests, provisioning, deployments
    └── Local:     /Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy
```

---

## Fix Applied

Added permanent `> [!CAUTION]` block to `blaze-actions/README.md` and this learning file.

---

## Prevention Rules (MUST FOLLOW)

1. **NEVER** run `gh workflow run` from `/Users/marek/Workspace/thisisblaze/blaze-actions`
2. **NEVER** check `gh secret list` on `blaze-actions` expecting deployment secrets
3. **NEVER** trigger stress tests from `blaze-actions`
4. **ALWAYS** switch to `blaze-template-deploy` for any actual run or secret lookup:
   ```bash
   cd /Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy
   gh workflow run stress-test-gcp.yml --ref dev -f environment=MULTI-SITE ...
   ```
5. When editing workflows in `blaze-actions` → the test run **must** happen from `blaze-template-deploy`

---

## Related Files

- `blaze-actions/README.md` — Library-only warning added
- `blaze-template-deploy/.github/workflows/` — Where actual runs happen
- `blaze-template-deploy/` secrets — Where all cloud credentials live

---

## Quick Reference

| Action | Wrong Repo | Correct Repo |
|--------|-----------|--------------|
| Run stress test | ❌ blaze-actions | ✅ blaze-template-deploy |
| Set GH_PAT secret | ❌ blaze-actions | ✅ blaze-template-deploy |
| Debug missing secrets | ❌ blaze-actions | ✅ blaze-template-deploy |
| Edit workflow logic | ✅ blaze-actions | — |
| Edit Terraform module references | ✅ blaze-actions | also blaze-template-deploy |
