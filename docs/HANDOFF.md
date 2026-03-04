# Session Handoff State

## Sprint Board

**Updated**: 2026-03-04T07:15Z

| Status  | Task                                                                | Assignee | Updated              |
| ------- | ------------------------------------------------------------------- | -------- | -------------------- |
| ⬜ TODO | Verify CF function state (`blaze-b9-thisisblaze-dev-cf-basic-auth`) |          | 2026-03-02T02:09:10Z |
| ⬜ TODO | Verify distribution has function attached                           |          | 2026-03-02T02:09:10Z |
| ⬜ TODO | (Optional) Fix `cleanup-orphaned-buckets` log groups pattern        |          | 2026-03-02T02:09:10Z |

### Done (This Sprint)

- [x] Create `deploy-azure-site.yml` reusable wrapper — Antigravity Session — 2026-03-04

---

# Session Journal

## Session Handoff — 2026-03-04T07:15Z

**Machine/Context**: Antigravity (Azure integration & workflows)

### 1. The Exact Objective

Complete the remaining Azure tasks from the March Roadmap while the user handles AWS tasks on another machine.

### 2. Current Progress & Modified Files

- `.github/workflows/deploy-azure-site.yml`: Created reusable workflow for Azure multi-site deployments with dual-tier traffic shifting.

### 3. Important Context

- Since the Azure apps architecture plan defines "Sites", the workflow supports both Tier 1 (Consumption/scale to zero) and Tier 2 (Dedicated Blue/Green).
- Tests are currently executing in `blaze-template-deploy`.

### 4. The Immediate Next Steps

> See Sprint Board tasks above.

---

## Session Handoff — 2026-03-02T02:09:10Z

**Machine/Context**: Previous User Session

### 1. The Exact Objective

Forensic investigation of unintended CloudFront function deletion is **complete**. The bug has been fixed and committed. Remaining action: verify the live `dev` CloudFront distribution still has `blaze-b9-thisisblaze-dev-cf-basic-auth` attached (it may be missing after the unintended deletion at 18:02Z, before the re-provision at 22:21Z corrected it).

### 2. Current Progress & Modified Files

- `.github/workflows/99-ops-utility.yml` — Two fixes applied and pushed:
  1. **`08ad553`** (18:22Z) — Scoped CF function deletion `PREFIX` to include `project_key` (`blaze-b9-thisisblaze`) instead of just `blaze-b9`. Prevents cross-project deletion.
  2. **`80e262d`** (02:09Z) — Added `sort -u` dedup on `list-functions` output and existence guard before `describe-function`. Prevents `NoSuchFunctionExists` exit-254 crash when API returns duplicate entries.

### 3. Important Context

### What happened (root cause)

- **Commit `f226fb2`** at `18:00:33Z` introduced the CF function delete step to the `cleanup-orphaned-buckets` action with an overly broad `PREFIX=blaze-b9` — matching `*blaze-b9*dev*` across ALL projects.
- **Run `22549226489`** at `18:01Z` ran `cleanup-orphaned-buckets` with `CONFIRM_MODE=EXECUTE` and deleted `blaze-b9-thisisblaze-dev-cf-basic-auth` (the function was unattached because the nuke at 07:29Z had destroyed distributions).
- The two other CF functions (`blaze-b9-dev-core-basic-auth`, `blaze-b9-thisisblaze-dev-admin-cdn-basic-auth`) were protected by AWS `FunctionInUse` errors.
- The script also crashed (exit 254) because `list-functions` returned the CF function name twice, causing `describe-function` to fail on a name that was already deleted.

### CloudTrail ground truth — CF function deletions today

| Time        | Function                                           | How                                                    |
| ----------- | -------------------------------------------------- | ------------------------------------------------------ |
| `07:28:54Z` | `blaze-b9-thisisblaze-dev-admin-cdn-basic-auth`    | Terraform nuke (intentional)                           |
| `07:29:23Z` | `blaze-b9-thisisblaze-dev-cf-basic-auth`           | Terraform nuke (intentional)                           |
| `07:29:24Z` | `blaze-b9-thisisblaze-dev-ecs-image-url-normalize` | Terraform nuke (intentional)                           |
| `18:02:54Z` | `blaze-b9-thisisblaze-dev-cf-basic-auth`           | `cleanup-orphaned-buckets` script ⚠️ **unintentional** |

### Distribution deletions

- 4 distributions deleted at 07:28–07:29Z (morning nuke, intentional)
- 29 distributions deleted at 20:05–22:26Z (evening nuke runs, intentional)
- All by Terraform via `BlazeGitHubActionsRole`. CloudFront distributions cannot be restored — re-provision recreates them with new IDs.

### Full deletion artifact

See `/Users/marek/.gemini/antigravity/brain/06fb6daf-716f-4fc6-b6e3-2770fff2c5cd/deletion_report_2026-03-01.md`

### Security status

- ✅ Overly broad CF function match — **FIXED** (`08ad553`)
- ✅ Dedup crash bug — **FIXED** (`80e262d`)
- ⚠️ `blaze-b9-thisisblaze-dev-cf-basic-auth` may still be missing from the live `dev` distribution — needs verification

### 4. The Immediate Next Steps

> Moved to Sprint Board.
