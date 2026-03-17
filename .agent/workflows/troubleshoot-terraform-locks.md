---
description: Troubleshoot and fix Terraform state lock issues (stale locks blocking workflows)
expected_output: Released Terraform state locks causing blocking pipelines.
exclusions: Do NOT force-unlock without verifying the lock is genuinely orphaned.
---

# Terraform State Lock Troubleshooting

**When to use:** Terraform workflows fail with "Error acquiring the state lock" or "ConditionalCheckFailedException"

## Quick Diagnosis

Run this to check for stale locks:

```bash
# Get lock info from workflow error message
LOCK_ID="<bucket>/<state-key>"  # From error: "Lock Info: Path: ..."
TABLE="<dynamodb-table>"         # Usually same as bucket name
REGION="eu-west-1"

# Check lock
aws dynamodb get-item \
  --table-name "$TABLE" \
  --key "{\"LockID\": {\"S\": \"$LOCK_ID\"}}" \
  --region "$REGION" \
  | jq '.Item.Info.S | fromjson | {Created, Who, Operation}'
```

## Root Causes

### 1. Cancelled Workflow (Most Common)

- **Symptom:** Lock persists for hours/days
- **Cause:** User cancels workflow while Terraform holds lock
- **Why:** GitHub Actions doesn't run cleanup steps on cancellation
- **Prevention:** Don't cancel workflows during Terraform operations

### 2. Workflow Timeout

- **Symptom:** Lock from >15 minutes ago
- **Cause:** Workflow hit timeout limit
- **Why:** Terraform didn't complete gracefully
- **Prevention:** Increase timeout-minutes or optimize Terraform

### 3. Runner Failure

- **Symptom:** Lock with "Who: runner@<id>" but no active workflow
- **Cause:** GitHub runner crashed/terminated unexpectedly
- **Why:** Infrastructure failure, no cleanup
- **Prevention:** Use stable runner infrastructure

## Automatic Fix

✅ **Automated since 2026-01-13:** Stale locks are now auto-released after 15 minutes!

The `reusable-terraform.yml` workflow includes:

```yaml
- name: Check & Release Stale Locks
  # Runs before every terraform plan
  # Checks lock age and auto-releases if >15 min old
```

**If automation fails,** use manual fix below.

## Manual Fix

### Option 1: Via GitHub Actions (Recommended)

```bash
# Trigger force-unlock workflow
gh workflow run "force-unlock.yml" \
  --repo thebyte9/blaze-template-deploy \
  --ref main
```

Then select:

- Environment: DEV/STAGE/PROD
- Stack: network/app/tunnel/etc

### Option 2: Via AWS CLI (Fast)

```bash
# Set variables from error message
BUCKET="b9-stage-blaze-tfstate"
STATE_KEY="infra/thisisblaze/stage/network.tfstate"
TABLE="$BUCKET"  # Usually same as bucket
REGION="eu-west-1"

# Delete lock
aws dynamodb delete-item \
  --table-name "$TABLE" \
  --region "$REGION" \
  --key "{\"LockID\": {\"S\": \"${BUCKET}/${STATE_KEY}\"}}"

echo "✅ Lock released"
```


## Prevention Checklist

- [ ] **Never cancel workflows during terraform plan/apply**
- [ ] **Set appropriate timeouts** (15min for network, 10min for app)
- [ ] **Monitor workflow duration** - alert if >10 minutes
- [ ] **Use apply=false first** - validate plan before applying
- [ ] **Check stale lock detection** - verify it's working monthly

## Common Lock IDs

```
# Network stack
b9-stage-blaze-tfstate/infra/thisisblaze/stage/network.tfstate

# App stack
b9-stage-blaze-tfstate/infra/thisisblaze/stage/app.tfstate

# Tunnel
b9-stage-blaze-tfstate/infra/thisisblaze/third-party/cloudflare.tfstate

# MongoDB
b9-stage-blaze-tfstate/infra/thisisblaze/third-party/mongodb.tfstate
```

## Monitoring & Alerts

### Recommended CloudWatch Alarm

```hcl
resource "aws_cloudwatch_metric_alarm" "terraform_locks" {
  alarm_name          = "terraform-stale-locks-${var.stage}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ItemCount"
  namespace           = "AWS/DynamoDB"
  period              = "300"  # 5 minutes
  statistic           = "Maximum"
  threshold           = "0"    # Alert if ANY locks exist
  alarm_description   = "Terraform state locks detected"

  dimensions = {
    TableName = var.state_bucket
  }
}
```

### Manual Check Script

```bash
#!/bin/bash
# check-all-locks.sh - Check for locks across all environments

for ENV in dev stage prod; do
  for STACK in network app; do
    TABLE="b9-${ENV}-blaze-tfstate"
    KEY="infra/thisisblaze/${ENV}/${STACK}.tfstate"

    LOCK=$(aws dynamodb get-item \
      --table-name "$TABLE" \
      --key "{\"LockID\": {\"S\": \"${TABLE}/${KEY}\"}}" \
      --region eu-west-1 2>/dev/null)

    if echo "$LOCK" | grep -q "Item"; then
      echo "🔒 LOCK FOUND: $ENV/$STACK"
      echo "$LOCK" | jq '.Item.Info.S | fromjson | {Created, Who}'
    fi
  done
done
```

## Technical Deep Dive

See: `/Users/marek/.gemini/antigravity/brain/.../terraform-lock-analysis.md`

**Key Bug (Fixed 2026-01-13):**

- Lock `Created` timestamp was inside `Info.S` JSON blob
- Previous code checked `.Item.Created.S` (doesn't exist!)
- Locks never detected as stale
- Fix: Parse `Info.S` first, then extract `Created`

## Emergency Contacts

If automation fails and manual unlock doesn't work:

1. Check AWS Console → DynamoDB → `<table>` → Items
2. Verify lock exists (search for LockID)
3. Delete item manually if needed
4. Report issue to infrastructure team

---

**Last Updated:** 2026-03-16  
**Auto-Fix Status:** ✅ Enabled  
**Success Rate:** 100% (tested with 11-hour-old lock)
