---
description: design and execute verification plans for infrastructure and code changes
expected_output: Clear, reproducible test outputs proving stability or failure of the system.
exclusions: Do NOT implement code fixes during this workflow. This is strictly a testing/verification workflow.

---

# Verification Workflow

This is the **orchestration guide** for the full verification cycle. Each phase is a separate workflow — they are decoupled by design so you never wait 30 min for a stress test.

```
Phase 1 (FAST ~3 min):   /02-dry-run         → Terraform plan, no changes applied
Phase 2 (FIRE ~30 sec):  /03-fire-stress-test → Fires test and returns immediately
                                                 🔔 You are FREE to do other work now
Phase 3 (ASYNC ~30 min): /03-monitor-stress   → Check back any time
Phase 4 (IF NEEDED):     /04-troubleshoot + /05-fix
Phase 5 (ALWAYS):        /12-stress-test-report
```

> [!IMPORTANT]
> **Do NOT wait after Phase 2.** The stress test runs in GitHub Actions in the background. Close this workflow, do other work, and come back with `/03-monitor-stress` when ready.

---

## Phase 1: Dry-Run (Terraform Plan)

Run `/02-dry-run` first. This is fast and blocking — wait for it.

```bash
# Triggers plan-only GitHub Actions run, waits for output
/02-dry-run <env> <layer>
```

**Success criteria:**

- `Plan: 0 to add, 0 to change, 0 to destroy` — clean ✅
- No unexpected resource recreates

**Stop condition:** If any `destroy` is detected — do NOT proceed to Phase 2. Investigate first.

---

## Phase 2: Fire Stress Test (Non-Blocking)

Only run this if Phase 1 passed clean.

```bash
/03-fire-stress-test <env>
```

This returns a **Run ID** in ~30 seconds. That's it. **You are done here** — the test runs for ~30 min in GitHub Actions.

---

## Phase 3: Monitor (Call Any Time)

Come back whenever. 10 min later, 30 min later, next session.

```bash
/03-monitor-stress          # auto-detects latest run
/03-monitor-stress <run_id> # specific run
```

---

## Phase 4: Fix (If Needed)

If Phase 3 shows failure:

```bash
/04-troubleshoot   # diagnose root cause
/05-fix            # implement fix
/02-dry-run        # re-validate
/03-fire-stress-test   # re-test
```

---

## Phase 5: Report (Always)

After a completed run (pass or fail):

```bash
/12-stress-test-report <run_id>
```

---

## Quick Reference: Image Resize Tests

For CloudFront / image resize changes specifically:

```bash
# Local
./tests/image-resize-test.sh <environment> cdn-<environment>.example.com

# CI/CD
gh workflow run test-image-resize.yml -f environment=<env>
```

Lambda@Edge logs (us-east-1 only):

```bash
aws logs tail /aws/lambda/us-east-1.blaze-{client}-{project}-<env>-lambda-edge-resize-image-viewer-request \
  --region us-east-1 --since 10m --follow
```

> **System Context**: BEFORE executing this workflow, you MUST read and adopt the persona defined in [AGENT_PERSONA_SRE_DAEMON.md](file:///docs/prompts/AGENT_PERSONA_SRE_DAEMON.md).

> **New: Automated Test Capability** (2026-01-13):
> For CloudFront and image resize infrastructure, use the automated test suite:
>
> - **Local**: `./tests/image-resize-test.sh <environment> <domain>`
> - **CI/CD**: `gh workflow run test-image-resize.yml -f environment=<env>`
> - **Results**: JSON output in `test-results/`, GitHub Actions summary

## Testing Workflow

### 0. Agent TDD Requirements (Fixes & Features)
If this workflow is being used to authorize a fix (`/05-fix`), you **MUST** author and run a verification script or test harness that PROVES the system is currently broken *before* touching application or infrastructure code. 
- Do **NOT** proceed to fix the code until you have a failing test output or a clear reproduction step logged.

### 1. Define Success Criteria

Specify what constitutes a pass:

- **Infrastructure**: `terraform plan` succeeds, no drift
- **API Endpoints**: 200 OK response
- **Image Resize**: Automated test suite passes (100% success rate)
- **Performance**: Cache hit rate > 80%, cached response < 100ms

### 2. Baseline Check

Verify current system state:

```bash
# Infrastructure state
terraform plan

# API health
curl -I https://api-<stage>.example.com/health

# CloudFront distribution
aws cloudfront get-distribution --id <DISTRIBUTION_ID>
```

### 3. Execute Tests

**For Image Resize Changes**:

```bash
# Upload test images (first time only)
aws s3 cp test-images/ s3://blaze-{client}-{project}-<env>-image-resize/test/ --recursive

# Run automated tests
./tests/image-resize-test.sh <environment> cdn-<environment>.example.com

# Or via CI/CD
gh workflow run test-image-resize.yml -f environment=<env> -f upload_test_images=true
```

**For Other Infrastructure**:

- CloudFront headers: Check `Server`, `Via`, `X-Cache` headers
- WAF: Verify WAF rules if enabled (PROD only)
- DNS: Verify records resolve correctly (`dig` commands)

### 4. Validate Lambda@Edge (Image Resize)

```bash
# Check Lambda@Edge logs (us-east-1 only)
aws logs tail /aws/lambda/us-east-1.blaze-{client}-{project}-<env>-lambda-edge-resize-image-viewer-request \
  --region us-east-1 \
  --since 10m \
  --follow

# Check for errors
aws logs filter-log-events \
  --region us-east-1 \
  --log-group-name "/aws/lambda/us-east-1.blaze-{client}-{project}-<env>-lambda-edge-resize-image-viewer-request" \
  --filter-pattern "ERROR"
```

### 5. Confirm Results

**Automated Test Results**:

- Success rate: Must be 100%
- Cache hit rate: Must be > 80%
- Avg cached response: Must be < 100ms

**Manual Verification**:

- Check CloudFront cache behavior
- Verify Origin Shield hits (STAGE/PROD)
- Test Basic Auth if enabled (DEV only)

### 6. Final Validation

Perform end-to-end service check:

- User-facing URLs respond correctly
- Performance metrics within acceptable range
- No errors in CloudWatch logs
- Test results passed automated thresholds
