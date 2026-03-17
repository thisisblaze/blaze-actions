---
description: 🔧 Check engines — run a full diagnostic sweep across all 3 repos (docs, prompts, graphs, modules, security, hygiene, parity, workflows)
expected_output: A comprehensive 10-engine sweep read-out identifying health warnings.
exclusions: Do NOT apply fixes directly; this is a diagnostic-only sweep.
---

# Check Engines — Full Diagnostic Sweep

Run this mid-session or weekly. It scans all 3 repos, flags issues, and tells you which workflow to run to fix them.
**This is read-only — it reports but does NOT auto-fix or commit.**

## Repos

- `blaze-template-deploy`: `/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy`
- `blaze-actions`: `/Users/marek/Workspace/thisisblaze/blaze-actions`
- `blaze-terraform-infra-core`: `/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core`

## Engine 1: Docs Freshness Scan

For **each repo**, scan all `.md` files in `docs/` (exclude `docs/archive/`, `docs/reports/`):

1. `grep -rn "Last Updated" docs/ --include="*.md"` (exclude archive/reports)
2. Flag any file where the `Last Updated` date is **older than 30 days** from today.
3. For `blaze-template-deploy` only: flag any doc that mentions **only AWS** when GCP/Azure sections should also exist (check for "AWS" without "GCP" or "Azure" in the same file).

**If issues found → Recommend: `/09-maintain-docs`**

## Engine 2: Prompt Health Check

In `blaze-template-deploy`:

1. **Framework references**: Grep `docs/prompts/00_core/` for:
   - `"12-Domain"` — must be present (not "11-Domain")
   - `"5-Killchain"` or `"5 Kill-Chain"` — must be present (not "4")
   - All 3 providers: `"AWS"`, `"GCP"`, `"Azure"` — each must appear

2. **Slash command parity**:
   - List all `.md` files in `.agent/workflows/` across all 3 repos using directory listing tools.
   - Use `grep_search` to find slash command definitions in `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md` and extract the workflow list. Do **NOT** read the entire prompt file.
   - Flag any workflow file that is NOT referenced in the system prompt.

3. **Stale prompts**: Check `Last Updated` dates in `docs/prompts/` files using grep — flag any > 30 days old.

**If issues found → Recommend: `/11-maintain-prompts-ai`**

## Engine 3: Graph Drift Detection

In `blaze-template-deploy`:

1. List all `.mermaid` files in `docs/graphs/`.
2. Use `grep_search` on `docs/graphs/README.md` to verify if the discovered `.mermaid` files are listed. Do **NOT** read the whole README.
3. **Quick structural check** (for `module_dependency_map.mermaid` only):
   - List actual module directories in `blaze-terraform-infra-core/modules/`
   - Use `grep_search` to find referenced modules in the `docs/graphs/module_dependency_map.mermaid` file. Do **NOT** read the entire file.
   - Flag modules that exist in code but not in the graph (new untracked modules).

**If issues found → Recommend: `/slash-weekly-graph`**

## Engine 4: Module Version Alignment

1. Get the latest tag from `blaze-terraform-infra-core`:
   ```
   cd /Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core
   git tag --sort=-v:refname | head -1
   
   cd /Users/marek/Workspace/thisisblaze/blaze-actions
   git tag --sort=-v:refname | head -1
   ```
2. In `blaze-template-deploy`, test both Terraform and GitHub Actions references:
   ```
   # Check Terraform modules
   grep -rn "ref=" .github/aws/infra/live/ .github/gcp/infra/live/ .github/azure/infra/live/ --include="*.tf"
   
   # Check GitHub Actions workflows
   grep -rn "uses: thisisblaze/blaze-actions" .github/workflows/ --include="*.yml"
   ```
3. Flag:
   - Any Terraform stack using a `ref=` **different** from the latest `blaze-terraform-infra-core` tag.
   - Any GitHub Actions workflow using a `@v` tag **different** from the latest `blaze-actions` tag (or still using `@dev`).
   - Any **version inconsistency** between environments (e.g., stage on `v1.50.0` but prod on `v1.49.0`).

4. **If refs were bumped** (either now or in a previous session), run dry-run validation on each affected stack:
   - For each provider/env combo with updated refs, trigger a **plan-only** run:
     ```
     Workflow: 01 ⚙️ Provision Infrastructure
     Layer: network (then app)
     Environment: dev → stage → prod
     ☐ Run Terraform Apply (unchecked = dry run)
     ```
   - Alternatively, if running locally with `act` or direct Terraform:
     ```bash
     cd .github/aws/infra/live/<stack>
     terraform init -upgrade
     terraform plan
     ```
   - Flag any plan that shows **unexpected destroys or recreates** — these indicate breaking changes in the new module version.
   - If all plans are clean (no unexpected changes), mark Engine 4 as ✅.

**If version drift found → Recommend: update `ref=` in affected `main.tf` files, then dry-run each stack**

## Engine 5: Security Pattern Scan

Grep across **all 3 repos** for banned patterns:

```bash
# Run in each repo
grep -rn "AWS_ACCESS_KEY_ID" --include="*.yml" --include="*.tf" --include="*.sh" .
grep -rn "ARM_CLIENT_SECRET" --include="*.yml" --include="*.tf" --include="*.sh" .
grep -rn "GCP_SA_KEY\|credentials_json" --include="*.yml" --include="*.tf" --include="*.sh" .
grep -rn "hardcoded.*password\|password.*=" --include="*.tf" . | grep -v "random_password\|var\.\|each\.value\|ec_deployment" || true
```

Exclude matches inside `docs/` and `archive/` (those are documentation references, not real usage).

**If banned patterns found → Recommend: `/08-audit`**

## Engine 6: Loose File & Hygiene Check

1. **Loose reports** (deploy repo):

   ```
   find docs/reports/ -maxdepth 1 -type f -name "*.md" ! -name "README.md" ! -name "ENV_COMPARISON_AWS.md"
   ```

   Flag any files found (should be in `YYYY/MM/` subdirectories).

2. **Temp artifacts** (all 3 repos):

   ```
   find . -type d \( -name "scratch" -o -name "temp" -o -name "debug" -o -name "*_src" \) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null
   ```

   Flag any non-empty temp directories.

3. **Uncommitted changes** (all 3 repos):

   ```
   git status --porcelain
   ```

   Flag any uncommitted files (informational, not blocking).

4. **.gitignore coverage** (all 3 repos):
   Check these patterns exist in `.gitignore`:
   - `scratch/`
   - `*.log`
   - `.env`

**If loose files found → Recommend: manual cleanup or `/09-maintain-docs` for report organization**

## Engine 7: Cross-Environment Stack Parity

In `blaze-template-deploy`:

1. **AWS stacks**: Compare module blocks between:
   - `.github/aws/infra/live/stage-network/main.tf` vs `prod-network/main.tf`
   - `.github/aws/infra/live/stage-app/main.tf` vs `prod-app/main.tf`
2. **GCP stacks** (if they exist): Same comparison for stage vs prod.
3. **Azure stacks** (if they exist): Same comparison for stage vs prod.

For each pair:

- Extract `module "xxx"` block names from each file.
- Flag any module present in one environment but **missing** from its counterpart.
- Flag any **provider version differences** between paired stacks.

4. **ENV Comparison Report audit** (`docs/reports/ENV_COMPARISON_AWS.md`):
   - `grep -n "Last Updated"` to check if the date is current.
   - `grep -n "🔴"` to list open critical action items — flag any unresolved ones.
   - Validate key invariants with quick greps (do NOT read the whole report):
     - `grep -n "enable_waf" .github/aws/infra/live/dev-network/main.tf` → must be `false`
     - `grep -n "ref=" .github/aws/infra/live/dev-app/main.tf` → must NOT be `ref=dev`
     - `grep -n "public_subnets" .github/aws/infra/live/prod-data/main.tf` → must be empty (Redis on private)
   - Compare the environments in the report with code: `dev-mini`, `dev`, `stage`, `prod`, `multi-site` must all have table columns.

**If drift found → Recommend: `/cross-environment-consistency`**  
**If report stale → Recommend: `/01-analyze` or update `ENV_COMPARISON_AWS.md` directly**

## Engine 8: Workflow & Slash Command Inventory

1. **Collect** all `.md` files from `.agent/workflows/` in each repo:

   ```
   # deploy
   ls .agent/workflows/*.md
   # actions
   ls .agent/workflows/*.md
   # infra-core
   ls .agent/workflows/*.md
   ```

2. **Cross-reference**: Read `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md` and check if all workflows are mentioned.

3. **Orphan detection**:
   - Flag any workflow `.md` that references a GitHub Actions file (`.github/workflows/*.yml`) that does NOT exist (ignore placeholders with `<` or `*`).
     - **Exception**: Ignore `debug-cicd-workflows.md` and `02-add-sharp-layer.md` as they intentionally cross-reference workflows between repos.
   - Flag any workflow with a `description:` frontmatter that is empty or missing.

4. **Turbo safety**: Flag any workflow with `// turbo` where the immediately following code block contains `destroy`, `delete`, `rm -rf`, `git push`, or `terraform apply`.

**If orphans or safety issues found → Recommend: `/11-maintain-prompts-ai`**

## Engine 9: Stress Test Health

In `blaze-template-deploy`:

1. **Coverage freshness**: Read `docs/reports/stress-tests/STRESS_TEST_REPORTS.md` — parse the Trend Summary table for the latest mini runs (`~7m (mini)`).
   - If the most recent **mini** run for AWS, GCP, or Azure is **older than 7 days** from today: flag it.
   - Note: We intentionally exclude `(full-circle)` and `(standard)` runs from the freshness alert as they are manually triggered and less frequent.

2. **Run report existence**: List files in `docs/reports/stress-tests/runs/`.
   - For each date in the Coverage Matrix, verify the corresponding run report file exists (e.g., `2026-02-21-aws-dev.md`).
   - Flag any matrix entry that links to a non-existent file.

3. **Guide coverage**: Verify these files exist:
   - `docs/prompts/03_manual/STRESS_TEST_GUIDE.md` ✅
     Flag if missing.

4. **Known Issues tracker**: Read the Known Issues table in the hub. Flag any issue marked `🔴` severity that has been open >30 days.

**If issues found → Recommend: `/12-stress-test-report` (to generate missing reports) or run the stress test workflow**

## Engine 10: Knowledge Library Health

In `blaze-actions`:

1. **Inventory**: List all `.md` files in `docs/knowledge/` (excluding `README.md`).
2. **Index Check**: Read `docs/knowledge/README.md`.
3. **Validation**:
   - Flag any `.md` file in the folder that is **NOT** linked in the `README.md`.
   - Flag any broken links in the `README.md` pointing to non-existent files.

**If orphans or broken links found → Recommend: Update `docs/knowledge/README.md`**

---

## Final Output: Dashboard Report

After running all 8 engines, output a compact dashboard:

```
🔧 CHECKENGINES REPORT — <date>

ENGINE 1 — DOCS FRESHNESS:        ✅ OK | ⚠️ N stale files
ENGINE 2 — PROMPT HEALTH:         ✅ OK | ⚠️ issues found
ENGINE 3 — GRAPH DRIFT:           ✅ OK | ⚠️ drift detected
ENGINE 4 — MODULE VERSIONS:       ✅ OK | ⚠️ N misaligned
ENGINE 5 — SECURITY PATTERNS:     ✅ OK | 🔴 banned pattern found
ENGINE 6 — HYGIENE:               ✅ OK | ⚠️ N loose files
ENGINE 7 — CROSS-ENV PARITY:      ✅ OK | ⚠️ drift found | ⚠️ ENV_COMPARISON_AWS stale or open 🔴 items
ENGINE 8 — WORKFLOW INVENTORY:    ✅ OK | ⚠️ orphans found
ENGINE 9 — STRESS TEST HEALTH:    ✅ OK | ⚠️ overdue / missing reports
ENGINE 10 — KNOWLEDGE LIBRARY:    ✅ OK | ⚠️ orphans / broken links

DETAILS:
  [List specific findings per engine, grouped]

RECOMMENDED ACTIONS:
  → /09-maintain-docs (Engine 1, 6)
  → /11-maintain-prompts-ai (Engine 2, 8)
  → /13-deep-cicd-maintenance (Engine 1, 2, 8; for active deep sync of docs, prompts, and timestamps)
  → /slash-weekly-graph (Engine 3)
  → Manual ref= update (Engine 4)
  → /08-audit (Engine 5)
  → /cross-environment-consistency (Engine 7)
  → /12-stress-test-report or run stress test (Engine 9)
  → Manual README.md update (Engine 10)

All engines green? "Things are only impossible until they're not." - Captain Jean-Luc Picard 🖖
```
