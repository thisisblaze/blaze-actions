---
description: 🖖 Engage — pulls latest, audits governance across all 3 repos, loads context
---

// turbo-all

# Start-of-Day Setup

Run this when you start work. It pulls latest code, does a quick governance health check, and loads AI context.

## Repos

- `blaze-template-deploy`: `/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy`
- `blaze-actions`: `/Users/marek/Workspace/thisisblaze/blaze-actions`
- `blaze-terraform-infra-core`: `/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core`

## Steps

### 1. Pull Latest (All 3 Repos)

Run `git pull` in each repo to ensure you're working on the latest code.

### 2. Quick Governance Health Check

For each repo, verify the 14 standard governance files exist:

`.cursorrules`, `.github/copilot-instructions.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/dependabot.yml`, `.antigravityignore`, `.cursorignore`, `.gitignore`, `CONTRIBUTING.md`, `CHANGELOG.md`, `LICENSE`, `README.md`, `docs/AI_CONTEXT_GOVERNANCE.md`, `.agent/config.yml`, `.agent/workflows/09-maintain-docs.md`

Report any missing files immediately.

### 3. Load Context (Hub Repo)

Read `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md` from `blaze-template-deploy`.

**CRITICAL TOKEN FRUGALITY RULE:**
Do **NOT** automatically read `AI_CONTEXT_GOVERNANCE.md`, architecture graphs, or the knowledge library on startup.
Instead, explicitly ASK the user:

> "Do you want me to load a specific Cloud Context? Reply with `/slash-init-context aws`, `/slash-init-context gcp`, or `/slash-init-context azure`."

### 4. Check for Overnight Changes

For each repo, run `git log --oneline -5` and report the last 5 commits.
Flag any commits from other contributors or CI bots that may need attention.

### 4.5. Stress Test Freshness

Check `docs/reports/stress-tests/STRESS_TEST_REPORTS.md` — read the **Coverage Matrix** table.

For each cell that has a date (not `⬚`):

- If the date is **older than 7 days**, flag it: `⚠️ Stress test overdue: AWS {stage} (last: YYYY-MM-DD)`
- If a stress test is currently `🔄 Running`, note it in the report.

Include in the Ready Report under a `STRESS TESTS:` line.

### 5. Ready Report

Output:

```
🟢 START-OF-DAY REPORT — <date>

REPO STATUS:
  deploy:     ✅ pulled | 14/14 files | branch: <branch>
  actions:    ✅ pulled | 14/14 files | branch: <branch>
  infra-core: ✅ pulled | 14/14 files | branch: <branch>

CONTEXT: Loaded (Multi-Cloud AWS/GCP/Azure)
RECENT ACTIVITY: <summary of last commits>
STRESS TESTS: <last run dates per stage, flag if >7 days overdue>

Ready to work. "Live long and prosper." - Spock 🖖
```
