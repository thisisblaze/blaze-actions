# Session Handoff State

## Sprint Board

**Updated**: 2026-03-04T08:22Z

| Status  | Task                                                                | Assignee | Updated              |
| ------- | ------------------------------------------------------------------- | -------- | -------------------- |
| ⬜ TODO | Verify CF function state (`blaze-b9-thisisblaze-dev-cf-basic-auth`) |          | 2026-03-02T02:09:10Z |
| ⬜ TODO | Verify distribution has function attached                           |          | 2026-03-02T02:09:10Z |
| ⬜ TODO | (Optional) Fix `cleanup-orphaned-buckets` log groups pattern        |          | 2026-03-02T02:09:10Z |
| ⬜ TODO | Fix Azure Stress Test — STILL FAILING (see below)                   |          | 2026-03-04T08:22Z    |

### Done (This Sprint)

- [x] Create `deploy-azure-site.yml` reusable wrapper — Antigravity Session — 2026-03-04
- [x] Add `concurrency` blocks to `deploy-azure-site.yml` + `reusable-azure-multi-site-deploy.yml` — 2026-03-04
- [x] Remove `deploy-sites-multi-site-azure` job from `02-deploy-app.yml` (was the first cause of GitHub's 20-reusable-workflow limit being hit) — 2026-03-04

---

# Session Journal

## Session Handoff — 2026-03-04T08:22Z

**Machine/Context**: Antigravity (Azure Stress Test debugging)

### 1. The Exact Objective

**Fix the Azure Stress Test** — it fails silently every time. Jobs like `provision-network`, `provision-data`, `provision-app`, `deploy-frontend` are all **skipped** even on fresh runs. The overall run reports `conclusion: failure`.

### 2. Current Progress & Modified Files

- `.github/workflows/02-deploy-app.yml`: Removed `deploy-sites-multi-site-azure` job (was one call over the limit). **Committed & pushed** to `dev`.
- `.github/workflows/deploy-azure-site.yml`: Added `concurrency:` block. **Committed & pushed** to `dev`.
- `.github/workflows/reusable-azure-multi-site-deploy.yml`: Added `concurrency:` block. **Committed & pushed** to `dev`.

### 3. Important Context & Root Cause Analysis

**The stress test STILL FAILS** after removing `deploy-sites-multi-site-azure` from `02-deploy-app.yml`.

**GitHub Actions hard limit**: A called workflow (e.g. `stress-test-azure.yml`) + all its reusable workflow dependencies **cannot exceed 20 reusable workflow references total** across the entire call tree. GitHub parses the entire tree at workflow start, and if the tree is too large, jobs silently fail to queue.

**Current count in `stress-test-azure.yml` call tree**:

- `stress-test-azure.yml` itself calls `02-deploy-app.yml@dev` at line 514 (`deploy-frontend` job)
- `02-deploy-app.yml` currently has **13 `uses: ./.github/workflows/*.yml` references**
- `stress-test-azure.yml` directly calls `reusable-calculate-config.yml` + **10 × `reusable-terraform-operations.yml`** = 11 more
- Total: **≥24 reusable workflow references** → still over the 20 limit

**The `deploy-frontend` job** at line 512 calls `02-deploy-app.yml` which contains many other cloud provider deploy jobs (AWS ECS, GCP Cloud Run, etc.) that are never used in the Azure stress test — but they still count toward the limit.

**The fix**: The `deploy-frontend` step in `stress-test-azure.yml` shouldn't call the heavy `02-deploy-app.yml`. It should call a **lighter dedicated Azure deploy workflow** directly (e.g. `reusable-container-app-deploy.yml`) — or skip the app deploy in the stress test entirely and only test infrastructure (provision → verify endpoints → destroy).

### 4. The Immediate Next Steps

1. **Open `stress-test-azure.yml` lines ~500-560** — find the `deploy-frontend` job that calls `02-deploy-app.yml@dev`
2. **Replace** the `02-deploy-app.yml` call with a direct call to `reusable-container-app-deploy.yml` or make the deploy step optional (add an `if: inputs.mode == 'deploy'` guard so it skips in infra-only stress test runs)
3. **Recount** the total reusable workflow references — must be ≤ 20
4. Push to `dev` and re-trigger the stress test: `gh workflow run stress-test-azure.yml -f environment=dev -f mode=full-circle -R thebyte9/blaze-template-deploy`
5. Monitor: `gh run list --workflow=stress-test-azure.yml --limit=3`
6. After Azure stress test passes → tackle the **ghost VPC** (`vpc-031151dd2c07f8ab7`) via `99-ops-utility.yml` workflow (destroy-resources, aws, dev, network stack)

**ENV Comparison Report Status** (`docs/reports/ENV_COMPARISON_AWS.md`):

- Open 🟡 action items:
  - Run AWS Stage stress test (overdue)
  - Review NAT policy if any env scales below 5 services → switch to `nat_strategy=NONE`
- WAF policy: CloudFront-only (stage/prod). ALBs are internal.
- NAT policy: GATEWAY when >5 services, NONE otherwise.
- Redis: prod-only. Private subnets, transit encryption enabled.
