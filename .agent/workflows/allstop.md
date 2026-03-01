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

### 5.7. ENV Comparison Report Check

In `blaze-template-deploy`, verify `docs/reports/ENV_COMPARISON_AWS.md`:

1. Check the `Last Updated` date — if changes were made to any `live/*/main.tf` today, the report must be updated.
2. Verify the **Action Items** table: mark any completed items as ✅ DONE.
3. Key invariants to re-validate quickly (`grep` only — do NOT read the full file):
   - `enable_waf` in `dev-network/main.tf` must be `false` (WAF is CF-only, stage/prod)
   - All `*-network` module refs should match the latest infra-core tag
   - `prod-data/main.tf` Redis subnet should reference `private_subnets`

**If the report is stale → update `Last Updated` and sync Action Items before committing.**

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
