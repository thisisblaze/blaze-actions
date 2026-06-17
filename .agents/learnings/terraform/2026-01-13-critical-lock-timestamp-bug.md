# Terraform State Lock - Info.S JSON Parsing Bug

**Auto-captured:** 2026-01-13T10:08:56Z  
**Trigger:** root_cause_analysis (critical bug, complexity 9)  
**Category:** terraform  
**Complexity:** 9/10  
**Impact:** 11-hour outage, blocking all STAGE provisioning

---

## Problem/Error

**Symptom:**

```
Error: Error acquiring the state lock
Error message: ConditionalCheckFailedException: The conditional request failed
Lock Info:
  ID:        252270cc-bb90-ca13-14ef-69816f78b172
  Created:   2026-01-12 23:36:56.550859233 +0000 UTC
```

Stale lock existed for 11+ hours but auto-detection didn't release it.

**Context:**

- File: `.github/workflows/reusable-terraform.yml`
- Workflow: All terraform operations blocked
- Environment: STAGE network stack
- Lock table: DynamoDB `b9-stage-blaze-tfstate`

---

## Root Cause

**Critical bug in lock timestamp parsing:**

The stale lock detection code was checking for `Created` timestamp at wrong JSON level:

```yaml
# ❌ WRONG - Checked top-level (doesn't exist)
CREATED=$(echo "$LOCK_DATA" | jq -r '.Item.Created.S // empty')
# Returns: empty

# ✅ CORRECT - Info.S is JSON blob containing Created
INFO=$(echo "$LOCK_DATA" | jq -r '.Item.Info.S // empty')
CREATED=$(echo "$INFO" | jq -r '.Created // empty')
# Returns: "2026-01-12 23:36:56.550859233 +0000 UTC"
```

**DynamoDB structure:**

```json
{
  "Item": {
    "LockID": {"S": "..."},
    "Info": {"S": "{\"Created\":\"...\",\"Who\":\"...\"}"}  ← JSON blob!
  }
}
```

**Why it happened:**

1. Terraform stores lock metadata as JSON string in `Info.S`
2. Code assumed `Created` was top-level attribute
3. Empty value → age calculation failed
4. Lock never detected as stale
5. 11+ hour lock persisted

**Trigger:** Workflow cancellation by user during terraform operation

---

## Fix Applied

**Code changes:**

```yaml
# Extract Info JSON blob first
INFO=$(echo "$LOCK_DATA" | jq -r '.Item.Info.S // empty')

# Then parse Created from inside the blob
CREATED=$(echo "$INFO" | jq -r '.Created // empty')

# Calculate age
CLEAN_TS=$(echo "$CREATED" | awk '{print $1, $2}')
LOCK_EPOCH=$(date -d "$CLEAN_TS" +%s 2>/dev/null || echo "")

if [[ -n "$LOCK_EPOCH" ]]; then
   NOW_EPOCH=$(date +%s)
   AGE_MIN=$(( (NOW_EPOCH - LOCK_EPOCH) / 60 ))

   if [[ $AGE_MIN -gt 15 ]]; then
      echo "🔓 Releasing stale lock..."
      aws dynamodb delete-item ...
   fi
fi
```

**Files modified:**

- `.github/workflows/reusable-terraform.yml` (lines 196-257)

**Commit:** `2fdbf5f` → `1c471e7` - "fix: CRITICAL - properly parse Terraform lock timestamp from Info JSON"

---

## Prevention

**To avoid this in future:**

1. ✅ **Always check actual DynamoDB structure** - Don't assume JSON schema
2. ✅ **Test with real lock data** - Use actual DynamoDB queries
3. ✅ **Add verbose logging** - Echo parsed values for debugging
4. ✅ **Monitor lock table** - CloudWatch alarm for ItemCount > 0
5. ✅ **Don't cancel workflows** - Especially during terraform operations

**Automated prevention:**

- Lock now auto-released after 15 minutes
- Tested with 11-hour-old lock: ✅ Works
- Added detailed logging showing age calculation

---

## Related

**Root trigger:**

- Workflow cancellation leaves locks
- Post-cleanup doesn't run on cancel

**Similar bugs:**

- Any DynamoDB attribute parsing
- Nested JSON in string fields
- Date parsing cross-platform issues

**Workflows affected:**

- `01-provision-infra.yml`
- `99-ops-utility.yml` (destroy operations)
- Any terraform workflow

---

## Testing

**Verification:**

```bash
# Manually create test lock (old timestamp)
aws dynamodb put-item \
  --table-name "b9-stage-blaze-tfstate" \
  --item '{
    "LockID": {"S": "test/lock"},
    "Info": {"S": "{\"Created\":\"2026-01-12 10:00:00\"}"}
  }'

# Trigger provision workflow
gh workflow run "01-provision-infra.yml" \
  -f environment=STAGE \
  -f stack=network

# Check logs - should see:
# "🔓 Releasing stale lock (Age: Xh Ym)..."
```

**Test results:**

- ✅ 11-hour-old lock detected
- ✅ Lock released automatically
- ✅ Terraform plan succeeded
- ✅ No manual intervention needed

---

## Metrics

| Metric                | Value                        |
| --------------------- | ---------------------------- |
| **Outage duration**   | 11+ hours                    |
| **Blocked workflows** | 6 attempts                   |
| **Time to diagnose**  | 30 minutes                   |
| **Time to fix**       | 45 minutes                   |
| **Iterations to fix** | 2 (YAML syntax issue)        |
| **Impact radius**     | STAGE environment only       |
| **Blast radius**      | All network stack operations |
| **MTTR after fix**    | 0 (auto-recovery)            |

---

## AI Agent Notes

**Pattern recognized:** json-blob-parsing

**Root cause complexity:** 9/10 (required timeline analysis + DynamoDB structure investigation)

**Confidence in fix:** 100% (tested with actual 11h lock)

**Reusability:** 10/10 (affects all terraform workflows)

**Should create workflow guide:** ✅ Yes - Created `troubleshoot-terraform-locks.md`

**Should monitor:** ✅ Yes - Add CloudWatch alarm recommended

**Future enhancement:** DynamoDB TTL + Lambda auto-cleanup (architecture change)

---

**Auto-captured by AI Agent**  
**Status:** ✅ Critical bug fixed, ✅ Documented, ✅ Tested, ✅ Workflow guide created  
**Priority:** P0 (blocking production operations)
