---
description: 🖖 All stop — end-of-day governance sync across all 3 repos
---

// turbo-all

# End-of-Day Governance Sync

Run this at the end of your work session to ensure all governance files are in sync across all 3 repos.

## Repos

- `blaze-template-deploy`: `/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy`
- `blaze-actions`: `/Users/marek/Workspace/thisisblaze/blaze-actions`
- `blaze-terraform-infra-core`: `/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core`

## Steps

### 1. Standard File Audit

For EACH of the 3 repos, verify ALL of these files exist:

| File                                   | Must Exist |
| :------------------------------------- | :--------- |
| `.cursorrules`                         | ✅         |
| `.github/copilot-instructions.md`      | ✅         |
| `.github/PULL_REQUEST_TEMPLATE.md`     | ✅         |
| `.github/dependabot.yml`               | ✅         |
| `.antigravityignore`                   | ✅         |
| `.cursorignore`                        | ✅         |
| `.gitignore`                           | ✅         |
| `CONTRIBUTING.md`                      | ✅         |
| `CHANGELOG.md`                         | ✅         |
| `LICENSE`                              | ✅         |
| `README.md`                            | ✅         |
| `docs/AI_CONTEXT_GOVERNANCE.md`        | ✅         |
| `.agent/config.yml`                    | ✅         |
| `.agent/workflows/09-maintain-docs.md` | ✅         |

If any file is missing, create it following the patterns from the other repos.

### 2. Governance Content Sync

Check the 3 `docs/AI_CONTEXT_GOVERNANCE.md` files:

- **Shared sections** (Prime Directive, Golden Rule, Data Retention, Cost Control, Zero Trace, Cleanup Protocol, Cross-Repo Architecture) must be **identical** across all 3. If content was updated in one, propagate to the others.
- **Repo-specific sections** (Protocol/Bootstrap, Workflows, Key References) must reference only files that **exist in that repo**. Verify all referenced workflow paths actually exist.
- **Dates** must be updated to today if content was changed.
- **NO `file:///` absolute links** allowed — all links must be relative.

### 3. .cursorrules Freshness Check

For each repo, use `grep` to quickly scan `.cursorrules` to verify if it correctly reflects today's major changes:

- Does it still accurately reflect the repo's current patterns? (Use `grep` on specific sections, DO NOT read the entire file).
- If significant workflows or modules were added/changed today, update the relevant sections.

### 4. .gitignore Consistency Check

Verify these patterns exist in ALL 3 `.gitignore` files using `grep`:

- `**/.DS_Store`
- `scratch/`
- `*.log`
- `*.tmp` / `*.temp`
- `.env` / `.secrets`

Verify `.agent/` is **NOT** in any `.gitignore` (critical — it was previously gitignored in blaze-actions).

### 5. CHANGELOG Check

For each repo where commits were made today, verify `CHANGELOG.md` has an entry for today's changes. If not, add one under an `[Unreleased]` section.

### 5.5. Stress Test Report Check

In `blaze-template-deploy`:

1. Check if any stress test workflow ran today:
   ```bash
   gh run list --workflow=stress-test.yml --limit=5 --json createdAt,status,conclusion --repo thebyte9/blaze-template-deploy
   ```
2. If a run completed today, check if a corresponding report exists in `docs/reports/stress-tests/runs/` with today's date.
3. If a run completed but **no report exists**, flag it:
   `⚠️ Stress test ran today but no report generated — run /12-stress-test-report`

### 5.6. Knowledge Library Sync

In `blaze-actions`:

1. Verify `docs/knowledge/README.md` exists.
2. Ensure any new `.md` files added to `docs/knowledge/` today are properly linked in the `README.md` index.

### 5.7. ENV Comparison Report — Diff and Update

In `blaze-template-deploy`, run the following checks **every time** (not just when you think things changed).
This is a mechanical diff — execute the commands, compare output to report table, update if any mismatch.

#### A. Detect Changed Infra Files Today

// turbo

```bash
cd /Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy
git diff --name-only HEAD~5 HEAD -- '*.tf' | grep 'live/' | sort
```

If **any** `live/*/main.tf` appears in this output, the report table rows for that env MUST be verified.

#### B. Mechanical Variable Check (run always — fast greps)

// turbo

```bash
# WAF: dev must be false, stage/prod must be true
grep -h "enable_waf" \
  .github/aws/infra/live/dev-network/main.tf \
  .github/aws/infra/live/stage-network/main.tf \
  .github/aws/infra/live/prod-network/main.tf

# NAT strategy per env
grep -h "nat_strategy" \
  .github/aws/infra/live/dev-network/main.tf \
  .github/aws/infra/live/stage-network/main.tf \
  .github/aws/infra/live/prod-network/main.tf

# Module refs — must all match latest infra-core tag
grep -rh "ref=" .github/aws/infra/live/ --include="*.tf" | sort | uniq -c | sort -rn | head -20

# Redis subnet — prod-data must say private_subnets NOT public_subnets
grep -n "subnet" .github/aws/infra/live/prod-data/main.tf

# Redis enabled flags — dev/stage must be false, prod must be true
grep -rh "enable_redis" .github/aws/infra/live/ --include="*.tf"

# Image resize per env
grep -rh "enable_image_resize" .github/aws/infra/live/ --include="*.tf"

# separate_api_alb
grep -rh "separate_api_alb" .github/aws/infra/live/ --include="*.tf"
```

#### C. Compare Against Report Table

For each value returned above, check if it matches the corresponding cell in `docs/reports/ENV_COMPARISON_AWS.md`:

| Grep result                       | Expected in report               | Action if mismatch      |
| --------------------------------- | -------------------------------- | ----------------------- |
| `enable_waf = false` in dev       | `❌ off` in dev column           | Update WAF row          |
| `enable_waf = true` in stage/prod | `✅ Main+CDN CF` / `✅ All CF`   | Update WAF row          |
| `nat_strategy = "GATEWAY"`        | `GATEWAY (>5 svc)`               | Update NAT row          |
| `ref=v1.50.9` everywhere          | `v1.50.9` in module ref row      | Update module ref row   |
| `private_subnets` in prod-data    | `✅ private` in Redis Subnet row | Mark 🔴 resolved → ✅   |
| `public_subnets` in prod-data     | `🔴 currently public`            | Ensure bug is flagged   |
| `enable_image_resize = false`     | `❌ off` for that env            | Update image resize row |

#### D. Update the Report (mandatory if any mismatch found)

1. Open `docs/reports/ENV_COMPARISON_AWS.md`
2. Update the affected table row(s) — be surgical, change only the mismatched cells
3. Update `**Last Updated**` date with a brief change note, e.g. `2026-03-01 (fixed Redis subnet)`
4. Update the **Action Items** table: mark ✅ DONE any items now resolved
5. Stage the file — it will be included in the end-of-day commit (step 6)

> [!IMPORTANT]
> **This step is NOT optional if any grep output differs from the report.** The report is the single source of truth for environment state — it must always reflect actual code.

### 5.8. Micro-Session Handoff Check

Before committing, proactively ask yourself and the user:

> _"Are we stopping midway through a complex task? If the context window is large, we should run `/slash-handoff` to freeze the state before fully concluding this session."_

### 6. Commit and Push

For each repo that has changes:

```bash
git add -A
git status  # Review what's staged
git commit -m "chore: end-of-day governance sync — $(date +%Y-%m-%d)"
git push
```

### 7. Summary Report

Output a final table:

```
| Repo | Files OK | Governance Synced | CHANGELOG Updated | Pushed |
|:--|:--:|:--:|:--:|:--:|
| deploy | 14/14 | ✅ | ✅ | ✅ |
| actions | 14/14 | ✅ | ✅ | ✅ |
| infra-core | 14/14 | ✅ | ✅ | ✅ |
```

"I have been, and always shall be, your friend." - Spock 🖖
