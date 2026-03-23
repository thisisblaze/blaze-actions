---
description: Check status of a running or completed stress test — call any time after /03-fire-stress-test
expected_output: Live workflow run status, error extractions, and final completion confirmation.
exclusions: Do NOT cancel or restart the workflow run directly.

---

// turbo-all

# Monitor Stress Test

Call this at any point after firing a stress test — 5 min in or 35 min in. Works regardless of status.

## Inputs

Optionally ask for:

1. **Run ID** — if known. If not provided, auto-detect the latest stress test run.

## Steps

### 1. Get Status

// turbo

```bash
# If run_id provided:
gh run view <run_id> --repo thebyte9/blaze-template-deploy \
  --json status,conclusion,createdAt,updatedAt,jobs \
  --jq '{status,conclusion,createdAt,updatedAt,jobs:[.jobs[]|{name,status,conclusion,startedAt,completedAt}]}'

# Otherwise: list last 3 runs
gh run list --workflow=stress-test.yml --repo thebyte9/blaze-template-deploy \
  --limit=3 --json databaseId,status,conclusion,createdAt,displayTitle
```

### 2. Handle Each State

**If `in_progress`:**

- Calculate elapsed time (`now - createdAt`)
- Estimate remaining: `30min - elapsed`
- Show current running job from jobs list
- Output:

  ```
  ⏳ STRESS TEST RUNNING
    Run ID:   <id>
    Elapsed:  <N> min
    Est. remaining: ~<M> min
    Current job: <job_name>

  → Come back in ~<M> min and run /03-monitor-stress
  ```

**If `completed` with `success`:**

```bash
gh run view <run_id> --repo thebyte9/blaze-template-deploy --log 2>/dev/null | tail -100
```

Output:

```
  ✅ STRESS TEST PASSED
    Duration: <total>
    All jobs: ✅

  → Run /12-stress-test-report <run_id> to generate the report
```

**If `completed` with `failure`:**

```bash
gh run view <run_id> --repo thebyte9/blaze-template-deploy --log-failed --json steps --jq '.steps[].log'
```

Output:

```
  ❌ STRESS TEST FAILED
    Failed job: <name>
    Error summary: <lines>

  → Run /04-troubleshoot to diagnose
  → Run /05-fix after identifying the root cause
  → Re-fire after fix: /03-fire-stress-test <env>
```

**If no recent run found:**

```
  ⚠️ No recent stress test found.
  → Fire one with: /03-fire-stress-test <env>
```
