---
description: 🖖 Engage — pulls latest, audits governance across all 3 repos, loads context
---

// turbo-all

# Start-of-Day Setup

Run this when you start work. It pulls latest code, does a quick governance health check, and loads AI context.

---

## 🗺️ THREE-REPO ARCHITECTURE (Read Every Session)

This project spans **3 repositories** with strict dependency rules. Violating these causes invisible failures.

### Repo Map

| Repo | GitHub | Local Path | Role |
|------|--------|-----------|------|
| **`blaze-template-deploy`** | `thebyte9/blaze-template-deploy` | `/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy` | **Spoke / Hub** — Contains the actual Terraform stack configs (`live/`), the application code, and the GitHub Actions workflow triggers. **Workflows run here.** |
| **`blaze-actions`** | `thisisblaze/blaze-actions` | `/Users/marek/Workspace/thisisblaze/blaze-actions` | **Actions Hub** — Source of truth for ALL reusable GitHub Actions workflows (`.github/workflows/`). Also contains the `live/` Terraform stacks for `dev-mini` and other environments NOT present in `blaze-template-deploy`. |
| **`blaze-terraform-infra-core`** | `thisisblaze/blaze-terraform-infra-core` | `/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core` | **Module Hub** — Source of truth for ALL Terraform modules (`modules/`). Never contains live stacks. |

### Dependency Chain

```
blaze-template-deploy  ──triggers──▶  .github/workflows/ from blaze-actions
       │
       └── live/*/main.tf  ──sources modules──▶  blaze-terraform-infra-core
```

### ⚠️ Critical Rules (Burned In)

1. **GitHub Actions workflows are TRIGGERED from `blaze-template-deploy`** using `gh workflow run --repo thebyte9/blaze-template-deploy`.
   - DO NOT use `--repo thisisblaze/blaze-actions` for production infrastructure workflows.

2. **Terraform stack configs (`live/`) live in BOTH repos** but partitioned by environment:
   - `blaze-template-deploy`: `dev-network`, `dev-app`, `stage-*`, `prod-*`, `multi-site-*`
   - `blaze-actions`: `dev-mini-network`, `dev-mini-app`, and any NEW environments being bootstrapped

3. **Changes to Terraform modules** go to `blaze-terraform-infra-core` and must be **tagged** (e.g. `v1.49.0`) before `live/` stacks can reference them via `?ref=vX.Y.Z`. Using `?ref=dev` causes cache staleness — always use pinned **tags** for CI.

4. **Changes to `live/*/main.tf` module refs** must be applied to BOTH repos if the environment exists in both:
   - `blaze-template-deploy/.github/aws/infra/live/dev-network/main.tf`
   - `blaze-actions/.github/aws/infra/live/dev-network/main.tf`
   - Both must agree on the same `?ref=vX.Y.Z` to avoid split-brain.

5. **Reusable workflow logic** (`.github/workflows/reusable-*.yml`, `resource-importer/import.sh`, etc.) lives in `blaze-actions`. The `blaze-template-deploy` workflows call them via `uses: thisisblaze/blaze-actions/.github/workflows/...@dev`.

### Environment → Repo Mapping

| Environment | Terraform Stack Location | Workflow Trigger Repo |
|-------------|--------------------------|----------------------|
| `dev` | `blaze-template-deploy/.github/aws/infra/live/dev-network/` | `thebyte9/blaze-template-deploy` |
| `dev-mini` | `blaze-actions/.github/aws/infra/live/dev-mini-network/` | `thebyte9/blaze-template-deploy` (still) |
| `stage` | `blaze-template-deploy/.github/aws/infra/live/stage-network/` | `thebyte9/blaze-template-deploy` |
| `prod` | `blaze-template-deploy/.github/aws/infra/live/prod-network/` | `thebyte9/blaze-template-deploy` |

### Future Ephemeral CIDR Allocation

| Env | VPC Range | Notes |
|-----|-----------|-------|
| `dev` | `10.0.0.0/16` | Primary, always-on |
| `dev-mini` | `10.1.0.0/16` | Ephemeral, spin up/down |
| `stage` | `10.2.0.0/16` | Always-on |
| `prod` | `10.3.0.0/16` | Always-on |
| `multi-site` | `10.4.0.0/16` | Permanent (nukes OK) |
| Future ephemeral | `10.5.0.0/16`, `10.6.0.0/16` ... | |

---

## Steps

### 1. Pull Latest (All 3 Repos)

Run `git pull origin dev` (or current branch) in each repo.

### 2. Quick Governance Health Check

For each repo, verify the 14 standard governance files exist:

`.cursorrules`, `.github/copilot-instructions.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/dependabot.yml`, `.antigravityignore`, `.cursorignore`, `.gitignore`, `CONTRIBUTING.md`, `CHANGELOG.md`, `LICENSE`, `README.md`, `docs/AI_CONTEXT_GOVERNANCE.md`, `.agent/config.yml`, `.agent/workflows/09-maintain-docs.md`

Report any missing files immediately.

### 3. Module Ref Consistency Check

Run this quick sanity check across both repos to catch any split-brain on module versions:

```bash
echo "=== blaze-template-deploy ===" && grep "ref=" /Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.github/aws/infra/live/dev-network/main.tf | head -3
echo "=== blaze-actions ===" && grep "ref=" /Users/marek/Workspace/thisisblaze/blaze-actions/.github/aws/infra/live/dev-network/main.tf | head -3
echo "=== infra-core latest tag ===" && git -C /Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core tag | sort -V | tail -3
```

Flag immediately if `blaze-template-deploy` and `blaze-actions` disagree on the module `?ref=`.

### 4. Load Context (Hub Repo)

Read `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md` from `blaze-template-deploy`.

**CRITICAL TOKEN FRUGALITY RULE:**
Do **NOT** automatically read `AI_CONTEXT_GOVERNANCE.md`, architecture graphs, or the knowledge library on startup.
Instead, explicitly ASK the user:

> "Do you want me to load a specific Cloud Context? Reply with `/slash-init-context aws`, `/slash-init-context gcp`, or `/slash-init-context azure`."

### 5. Check for Overnight Changes

For each repo, run `git log --oneline -5` and report the last 5 commits.
Flag any commits from other contributors or CI bots that may need attention.
Flag if `blaze-terraform-infra-core` has new commits NOT yet tagged (would be behind `live/` stacks).

### 5.5. Stress Test Freshness

Check `docs/reports/stress-tests/STRESS_TEST_REPORTS.md` — read the **Coverage Matrix** table.

For each cell that has a date (not `⬚`):

- If the date is **older than 7 days**, flag it: `⚠️ Stress test overdue: AWS {stage} (last: YYYY-MM-DD)`
- If a stress test is currently `🔄 Running`, note it in the report.

Include in the Ready Report under a `STRESS TESTS:` line.

### 6. Ready Report

Output:

```
🟢 START-OF-DAY REPORT — <date>

REPO STATUS:
  deploy (thebyte9):   ✅ pulled | 14/14 files | branch: <branch>
  actions (thisisblaze): ✅ pulled | 14/14 files | branch: <branch>
  infra-core:          ✅ pulled | 14/14 files | branch: <branch>

MODULE REF CHECK:
  deploy/dev-network:  ?ref=<version>
  actions/dev-network: ?ref=<version>
  infra-core head tag: <latest tag>
  ✅ In sync | ⚠️ SPLIT BRAIN DETECTED

CONTEXT: Loaded (Multi-Cloud AWS/GCP/Azure)
RECENT ACTIVITY: <summary of last commits>
STRESS TESTS: <last run dates per stage, flag if >7 days overdue>

WORKFLOW REMINDER: Always trigger via thebyte9/blaze-template-deploy
  gh workflow run "01-provision-infra.yml" --repo thebyte9/blaze-template-deploy ...

Ready to work. "Live long and prosper." - Spock 🖖
```
