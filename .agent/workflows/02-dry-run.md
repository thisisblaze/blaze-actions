---
description: Run Terraform plan-only (dry-run) for one or all AWS stacks — fast, no apply, no stress test
expected_output: Terraform plan outputs showing expected changes, with no live alterations.
exclusions: Do NOT execute terraform apply. Do NOT modify the tfstate.

---

// turbo-all

# Terraform Dry-Run

Fast, blocking plan check (~2-3 min per stack). Does **NOT** trigger a stress test — use `/03-fire-stress-test` for that separately.

## Inputs

Ask the user:

1. **Environment** — `dev`, `stage`, `prod`, `dev-mini`, `multi-site`, or `all`
2. **Layer** — `network`, `app`, `data`, or `all` (default: all layers for the env)

## Steps

### 1. Get Latest Module Tag

// turbo

```bash
cd /Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core
git tag --sort=-v:refname | head -1
```

Flag if any `main.tf` in the target env uses a different `ref=` value.

### 2. Trigger Dry-Run (Plan Only)

For each stack (network → app → data):

```bash
gh workflow run "01 ⚙️ Provision Infrastructure" \
  --repo thebyte9/blaze-template-deploy \
  -f environment=<env> \
  -f layer=<layer> \
  -f run_apply=false
```

Wait for completion:

```bash
gh run list --workflow="01*Provision*" --repo thebyte9/blaze-template-deploy --limit=3 --json databaseId,status,conclusion,createdAt
gh run watch <run_id> --repo thebyte9/blaze-template-deploy
```

### 3. Parse Plan Output

```bash
gh run view <run_id> --repo thebyte9/blaze-template-deploy --log --json steps --jq '.steps[] | select(.name | test("(?i)plan")) | .log'
```

Flag any:

- 🔴 `destroy` — stop immediately, do NOT apply
- ⚠️ unexpected resource recreates
- ✅ `Plan: 0 to add, 0 to change, 0 to destroy` — clean

### 4. Report

```
DRY-RUN REPORT — <env> / <layer> — <date>

  network:  ✅ Plan clean (0/0/0) | ⚠️ N changes | 🔴 DESTROY DETECTED
  app:      ✅ Plan clean (0/0/0) | ⚠️ N changes | 🔴 DESTROY DETECTED
  data:     ✅ Plan clean (0/0/0) | ⚠️ N changes | 🔴 DESTROY DETECTED

  Run IDs: <ids>
  Next: /03-fire-stress-test <env>   (if all plans are clean)
```

Stop and report to user if any destroys are detected — do NOT continue to stress test.
