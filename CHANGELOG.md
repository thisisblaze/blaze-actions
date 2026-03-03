# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-03-03

### Changed

- docs: end-of-day governance sync and AI Context updates

## [v1.5.2] - 2026-03-01

### Added

- **`cleanup-orphaned-buckets` ops action** (`99-ops-utility.yml`): New action to find and force-delete orphaned S3 buckets matching the project prefix (excludes tfstate). Accepts `DRY_RUN` or `EXECUTE` confirmation.
- **Orphaned Resource Cleanup — Extended** (`99-ops-utility.yml`): Added cleanup steps for orphaned CloudWatch Log Groups, ALB Target Groups, and CloudFront Functions within the `cleanup-orphaned-buckets` action to resolve Terraform `AlreadyExists` conflicts after partial environment destroy.
- **`gh-actions-troubleshooter` Antigravity Skill**: Created global Antigravity skill at `~/.gemini/antigravity/skills/gh-actions-troubleshooter/` implementing local-first PDCA diagnostic cycle, `get_failed_logs.sh`, `run_local_act.sh` (with `--doctor` check), and curated `ERROR_PATTERNS.txt` reference library.

### Fixed

- **Scope Safety — Cleanup Scripts** (`99-ops-utility.yml`): Corrected resource matching logic in all cleanup steps to strictly use `namespace-client_key-project_key-environment` exact prefix, preventing accidental deletion of resources from other projects sharing the same AWS account (e.g. `blaze-b9-dev-core-*`).
- **CF Function Dedup Crash** (`99-ops-utility.yml`): Fixed `NoSuchFunctionExists` exit-254 crash in the `cleanup-orphaned-buckets` action. `aws cloudfront list-functions` can return duplicate entries — if a function was deleted on loop iteration 1, the second pass would call `describe-function` on a now-gone name and crash. Fixed by: `sort -u` on list output to deduplicate, plus an existence guard (empty ETag check) before attempting `delete-function`.
- **CloudFront Destroy Ordering Workarounds Removed**: With `environment-network` v1.50.15 introducing the `terraform_data.cf_policy_destroy_gate` native fix, all CLI-based workarounds have been removed:
  - `99-ops-utility.yml`: Removed `terraform state rm` for CF cache policies (6 resources) and LB listeners (3 resources) from nuke network `pre_apply_script`.
  - `01-provision-infra.yml`: Removed the `if: destroy && stack == network` guard block with CF policy + LB listener state rm.
  - `reusable-pre-destroy-cleanup.yml`: Removed the 100+ line "🛑 Pre-Destroy CloudFront Distributions & Cache Policies" step (CLI disable/wait/delete logic).
  - Lambda@Edge state rm intentionally retained — valid workaround for AWS's multi-hour replica propagation delay.

## [v1.5.1] - 2026-02-28

### Changed

- infra: upgrade core modules to `v1.50.4` (fixes ALB logging `Access Denied` on prefixed paths)
- docs: AI_CONTEXT_GOVERNANCE updated with Section 11 (dual-ALB, VPC CIDRs, module v1.50.3, Lambda@Edge scope)
- docs: REPOSITORY_SYSTEM_PROMPT + PART_03 NotebookLM updated for dual-ALB architecture

## [v1.5.0] - 2026-02-27

### Added

- **DEV-MINI Environment**: New `DEV-MINI` GitHub environment created. Cloudflare Tunnel-only — no ALB, no CloudFront. Secrets propagated via `gh api`. `01-provision-infra.yml`, `02-deploy-app.yml`, and `stress-test.yml` all accept `DEV-MINI` as valid input.
- **Admin SPA Deploy (AWS CloudFront + S3)**: `02-deploy-app.yml` now includes an admin build + S3 sync step followed by CloudFront invalidation for AWS `DEV`/`STAGE`/`PROD` environments. `DEV-MINI` continues to deploy Admin via Cloudflare Pages.
- **Image Resize Verify on DEV**: `stress-test.yml` now runs image resize endpoint verification on the new `DEV` environment (mirrors STAGE).

### Changed

- **Native ECS Blue/Green (active)**: Removed all CodeDeploy references from deployment workflows. API service Blue/Green is now fully managed by ECS natively — no CodeDeploy application, deployment group, or `appspec.yml`. Strategy toggled via `enable_blue_green` (replaces `enable_codedeploy`).
- **DEV mirrors STAGE**: New `dev` Terraform stacks (`dev-app`, `dev-network`) now have full parity with `stage` — ALB, CloudFront, WAF, Image Resize, ECS Fargate. The previous tunnel-only `dev` is now `dev-mini`.

### Removed

- **CodeDeploy**: All `aws deploy create-deployment`, `appspec.yml`, and CodeDeploy IAM role references removed from `02-deploy-app.yml`, `deploy-site.yml`, and `99-ops-utility.yml` nuke pre-cleanup.

---

## [Unreleased] - 2026-02-25

### Added

- **Azure Multi-Site Deploy (`reusable-multi-site-deploy.yml`)**: New reusable workflow for deploying individual sites within the 120+ Azure Container Apps fleet.
  - Handles Tier 1 (standard): single revision, instant 100% traffic shift.
  - Handles Tier 2 (premium): multi-revision, staged traffic shift (e.g. 10% → 50% → 100% with 30s delays).
  - Integrates OIDC auth (`azure/login@v2`) and automated ACR token generation.

- **`deploy-site.yml`**: New reusable workflow for multi-site ARM64 deployments.
  - `build` job: Native `ubuntu-24.04-arm` runner — no QEMU, full Graviton build speed. Pushes to ECR with GHA layer caching scoped per `site_key`.
  - `deploy` job: Discovers ECS service by `site_key` suffix dynamically (no hardcoded prefix). Patches container image via `describe-task-definition` + `register-task-definition` + JQ — no task-def JSON files committed to the repo.
  - `rolling` strategy: `aws ecs update-service --force-new-deployment` + `ecs wait services-stable` (standard tier sites).
  - `blue-green` strategy: **Native ECS Blue/Green** — ECS manages the task set swap and traffic shift natively. No CodeDeploy required.
  - Full GitHub Step Summary on every run (build digest, service name, strategy, status).

- **Token Frugality Overhaul**: Major refactor of `/engage`, `/allstop`, `/checkengines`, and `/slash-init-context` to implement targeted context loading and the "Prime Directive" of minimal token usage.
- **Handoff Mechanism**: Added `/slash-handoff` and `/slash-resume` to allow for micro-session isolation and state preservation.

### Fixed

- **Azure Stress Test Parameter (`reusable-terraform-operations.yml`)**: Fixed severe `startup_failure` schema parser crash in Azure stress tests by explicitly providing the required `domain_root` input to `destroy-mongodb` and `final-destroy-mongodb` jobs.
- **Calculate Config Routing (`reusable-calculate-config.yml`)**: Fixed a CRITICAL routing issue where the `multi-site-network`, `multi-site-app`, and `multi-site-cdn` stacks were falling through to the default `${stage}-network` fallback, which injected the wrong TF_DIR and state keys. They now map correctly to `live/multi-site-*` and state `multi-site/*.tfstate`.
- **Nuke CodeDeploy Ordering (`99-ops-utility.yml`)**: Added `pre_apply_script` to Nuke 2/5 App Stack that `state rm`s orphaned CodeDeploy deployment groups before destroy. Fixes `InvalidRoleException` where IAM role is destroyed before the deployment group, and AWS API refuses deletion.

### Added

- **Azure Stress Test Reusable Workflow** (`reusable-azure-stress-test.yml`): New reusable workflow for running end-to-end Azure stress tests. Supports full provision → deploy → verify → optionally destroy lifecycle across Azure Container Apps environments.

### Fixed

- **GCP Resource Importer DNS Cleanup** (`resource-importer`): Added DNS record cleanup steps compatible with Cloudflare provider v4.52.0 to prevent orphaned DNS records on GCP environment teardown.
- **GCP Stress Test Destroy Order**: Swapped CDN and App destroy order to prevent orphaned NEGs (Network Endpoint Groups) when Cloud Run services are destroyed before the CDN/load balancer is cleaned up.
- **Workflow YAML Array Syntax**: Fixed invalid YAML array syntax in `needs` blocks identified during stress test debugging.

## [Unreleased] - 2026-02-23

### Added

- **Knowledge Library Docs**: Added new centralized documentation framework (`docs/KNOWLEDGE_LIBRARY.md`) and topic-specific deep dives (`docs/knowledge/smart_fixes/`, etc.)
- **Governance**: Synced `docs/AI_CONTEXT_GOVERNANCE.md` with Public Repository Sanitization rules.
- **`skip_stability_wait` for ECS deploys**: New input on `deploy-ecs-service/action.yml`, `reusable-ecs-deploy.yml`, and `02-deploy-app.yml`. When `true`, skips the `aws-actions/amazon-ecs-deploy-task-definition` stabilisation wait. The stress test now passes `skip_stability_wait: "true"` automatically to prevent 29-minute timeouts when deploying placeholder images to freshly provisioned infrastructure.

### Changed

- **Governance Sync**: Unified AI context documentation across repos.

### Fixed

- **OIDC Connectivity**: Applied `aws-actions/configure-aws-credentials` and `google-github-actions/auth` to `check-stack-exists.yml` to resolve OIDC "Credentials could not be loaded" errors.
- **Stress Test Verify**: 7 fixes to `stress-test.yml` verify logic:
  - Accept 530 for cold start + continue-on-error + 5 retries
  - Changed API check from `/graphql` to `/health`
  - Accept 401 for stage frontend/admin (Cloudflare basic auth)
  - Skip image resize check for stage (`enable_image_resize=false`)
  - Use ECS `services-stable` wait + public URL check instead of TG health
  - Added 90s ECS stabilization wait before verify
- **Nuke Workflow**: Added missing AWS data stack destroy + fix network cascade skip
- **CI Permissions**: Added `actions:write` permission to stress-test workflow

## v1.4.0-workflow-consolidation (2026-02-17)

### Added

- **Ops Utility Expansion**:
  - `cleanup-dns`: New action in `99-ops-utility.yml` to surgically remove DNS records (A, CNAME, TXT) and Cloudflare Pages projects for a specific environment.
  - `nuke-cloudfront`: New action in `99-ops-utility.yml` to forcefully disable and delete stuck CloudFront distributions.
- **Stress Test Validation**:
  - `stress-test.yml`: Validated for use as a reusable workflow via "Wrapper Pattern".

## v1.3.0-tunnel-stability (2026-02-17)

### Added

- **Cloudflare Tunnel Stability**:
  - Implemented "Split Apply" strategy to resolve API consistency issues between Tunnel creation and Configuration.
  - `reusable-terraform.yml`: Added `split_apply`, `split_targets`, and `sleep_seconds` inputs.
  - `reusable-terraform.yml`: Added logic to execute targeted apply -> sleep -> full apply when enabled.
- **Cleanup Hardening**:
  - `99-ops-utility.yml`: Enhanced Nuke Pages cleanup to delete domains before projects (Fixes "Project not found" race condition).
  - `99-ops-utility.yml`: Improved Cloudflare Cleanup logic.

## v1.2.0-multi-cloud-foundation (2026-02-16)

### Added

- **Multi-Cloud Foundation**:
  - `01-provision-infra.yml` & `02-deploy-app.yml` now accept `cloud_provider` input (aws, gcp, azure).
  - `reusable-terraform.yml`: Implemented split backend logic (S3/DynamoDB for AWS, GCS for GCP, Azure Blob for Azure).
  - `calculate-config`: Updated to output provider-specific state bucket formats (e.g., Azure `rg/sa/container`).
- **Hybrid ECS Refinements**:
  - `01-provision-infra.yml`: Added `api_launch_type` and `frontend_launch_type` inputs to support hybrid provisioning.
- **Mandatory Cleanup Protocol**:
  - `reusable-pre-destroy-cleanup.yml`: Added CRITICAL logic to forcefully detach/delete EC2 Capacity Providers and clean up Launch Templates to prevent Terraform destroy hangs.
  - `99-ops-utility.yml`: Integrated `reusable-pre-destroy-cleanup` into the `destroy-resources` job.

### Changed

- **Documentation Synchronization**:
  - Updated `REPOSITORY_SYSTEM_PROMPT.md` to enforce Cleanup Protocols and Hybrid Architecture.
  - Updated `DAILY_DOCUMENTATION_AUDIT.md` and `AI_CONTEXT_GOVERNANCE.md` to include Multi-Cloud and Cleanup checks.
  - Updated `REUSABLE_WORKFLOWS.md`, `WORKFLOW_CATALOG.md`, and `cross-org-secrets.md` to reflect the new capabilities.

## v1.1.0-hybrid-ecs (2026-02-09)

### Added

- **Hybrid ECS Deploy**: `02-deploy-app.yml` now supports `api_launch_type` (FARGATE/EC2) and `api_cpu_architecture` (X86_64/ARM64) inputs for per-service compute selection
- **Reusable ECS Deploy**: `reusable-ecs-deploy.yml` accepts `launch_type` and `cpu_architecture` inputs, passes them to task definition and service update
- **Deploy Action**: `deploy-ecs-service` composite action injects `LAUNCH_TYPE` and `CPU_ARCHITECTURE` into task definition JSON template
- **Task Definition Template**: `api.json` uses `"requiresCompatibilities": ["__LAUNCH_TYPE__"]` and `"cpuArchitecture": "__CPU_ARCHITECTURE__"` placeholders

### Changed

- **Multi-arch Docker Build**: `reusable-docker-build.yml` builds amd64 + arm64 in parallel on native runners, creates multi-arch manifest

## v1.0.0-fargate-stable (2026-02-07)

### Added

- feat: enable Flex tier for DEV environment (auto mode)
- feat: Update MongoDB tier auto-resolution (Dev=Flex, Stage/Prod=M10)
- feat: Enhance Provisioning Summary with deep links and rich details
- feat: enrich provisioning summary and improve cleanup logic
- feat: updates for hybrid pages, system monitor & dynamic namespace
- feat: enable stack-specific import hooks via pre_apply_script
- feat: passthrough enable_image_resize to terraform
- feat: restore provision job and add destroy input
- feat: add app stack support to resource importer
- feat: Execute import recovery script in reusable workflow
- feat: Integrate VPC integrity check into reusable workflow
- feat: add Lambda@Edge error detection to ops summary
- feat: add version-based Sharp layer caching with auto-rebuild
- feat: add CloudFront image resize details to network provisioning summary
- feat: add AI agent auto-learning system
- feat: automate Sharp Lambda Layer build in CI/CD for image resize
- feat: add automatic Cloudflare cache purge after admin deployment
- feat: auto-set Cloudflare Pages production branch in CI/CD
- feat: add automated CHANGELOG generation workflow

### Changed

- docs: daily documentation audit 2026-01-21
- docs: add infographic prompts for workflow visualizations
- docs: add NotebookLM prompt template with strict guidelines
- docs: add Slide deck and Infographic as top Studio features
- docs: update NotebookLM guide to focus on Studio features
- docs: add detailed NotebookLM usage guide
- docs: add Google NotebookLM presentation prompts
- docs: make daily audit prompt portable for all users
- docs: add daily documentation audit prompt (00_core)
- docs: comprehensive namespace configuration documentation
- refactor: remove redundant is_paused input from provision workflow
- docs: standardize metadata headers (Owner/Last Updated)
- chore: remove debug steps
- docs: update quick reference for 02-deploy-app and 99-ops-utility
- docs: enforce hybrid naming in system prompt
- docs: init repository system prompt with Mermaid and Hybrid Architecture standards
- docs: finalize removal of hardcoded examples
- docs: use dynamic namespace placeholders in operation guides
- docs: update catalog with strict 01/99 separation and live metrics
- docs: clarify 01 workflow is for creation only
- docs: update default skip_lambda_destroy value
- docs: explain reason for skip_lambda_destroy checkbox
- docs: skip_lambda_destroy in readme & checklist
- chore: full dump of lock table and fallback delete
- chore: add debug for lock table
- chore: increase terraform timeout to 60m
- docs: add terraform init -upgrade to CHANGELOG
- chore: add .agent/ to .gitignore for security
- docs: clarify DEV uses Cloudflare only (no CloudFront/image resize)
- docs: add comprehensive workflow guides for automation
- docs: update CHANGELOG with admin deployment fixes
- docs: add welcome section for external users

### Fixed

- fix: pass AWS credentials to health-check-script job
- fix: use steps.config.outputs instead of needs.configuration.outputs in Pre Apply Script
- fix: add nuke-destroy-pages to environment destruction
- fix: add image resize bucket to pre-destroy cleanup
- fix: add missing fi to shell script
- fix: remove lingering AWS_SECRET_ACCESS_KEY
- fix: remove lingering AWS_ACCESS_KEY_ID
- fix: remove unused AWS secrets from workflows
- fix: improve cloudflare cleanup to dynamically find ACM records
- fix: remove invalid secrets check in workflow conditional
- fix: add cloudflare record cleanup to nuke process
- fix: add zombie OAC and IAM role cleanup to nuke process
- fix: delete md5 digest for state recovery
- fix: correct yaml syntax for provision job and script
- fix: correct frontend target group naming (fe not frontend)
- fix: add network stack resource imports to prevent state drift
- fix: bash substitution error in Sharp layer output step
- fix: add -upgrade to terraform init to force module refresh
- fix: YAML syntax - use inline timestamp parsing
- fix: CRITICAL - properly parse Terraform lock timestamp from Info JSON
- fix: use sudo for all Docker file operations
- fix: use sudo for cleanup of Docker-created files
- fix: override Lambda Docker image entrypoint for Sharp build
- fix: use full repo path for build-sharp-layer action
- fix: use correct admin build output directory (public instead of dist)

## [Unreleased]

### Added

- **Hybrid ECS Support**: `calculate-config` now recognizes `account-settings` stack for ENI Trunking / Container Insights
  - New stack option in `01-provision-infra.yml`: `account-settings`
  - Maps to `.github/aws/infra/live/account-settings` directory
  - Required safety check: `deploy_infra` must be true

### 🚨 Breaking Changes

#### Namespace Hardcoding Removed - Dynamic Namespace Support

**Date:** 2026-01-20  
**Impact:** Resource naming now uses configurable namespace

All workflows now use dynamic `${{ needs.calculate-config.outputs.namespace }}` instead of hardcoded `"blaze"`. This enables:

- Multi-tenancy support
- Organizational isolation
- Custom resource naming prefixes
- Testing with different namespaces

**Resource Naming Pattern (Updated):**

```
${namespace}-${client_key}-${project_key}-${stage_key}-${resource}
```

**Files Changed:**

- `.github/workflows/00_setup_environment.yml` - S3 backend buckets & ECR repository naming
- `.github/workflows/02-deploy-app.yml` - ECS cluster name in deployment summary
- `.github/workflows/reusable-pre-destroy-cleanup.yml` - Resource cleanup with namespace extraction

**Default Behavior:**  
Namespace defaults to `"blaze"` for backward compatibility. Existing deployments are unaffected unless you explicitly change the namespace configuration.

**Migration Guide:**

To maintain existing resources (recommended for production):

```json
// vars/blaze-env.json
{
  "common": {
    "NAMESPACE": "blaze" // Explicitly set to current default
  }
}
```

To use a custom namespace (requires environment rebuild):

1. Export data from existing environment
2. Run nuke workflow to destroy resources
3. Update `NAMESPACE` in `vars/blaze-env.json` or `vars/${PROJECT_KEY}/blaze-env.json`
4. Re-provision infrastructure with `00_setup_environment.yml`
5. Restore data

> **⚠️ Warning:** Changing namespace for an existing environment requires complete rebuild. All AWS resources will be recreated with new names.

**Resources Affected:**

- S3 Buckets: `${client}-${stage}-${namespace}-tfstate`
- ECR Repositories: `${namespace}-${project}-web/*`
- ECS Clusters: `${namespace}-${client}-${project}-${stage}-cluster`
- IAM Roles: `${namespace}-${client}-${project}-${stage}-*-role`
- Lambda Functions: `${namespace}-${client}-${project}-${stage}-*`
- CloudFront OAC: `${namespace}-${client}-${project}-${stage}-cdn-oac`

### Changed

- **reusable-terraform.yml**: Added `-upgrade` flag to `terraform init` (commit: 9e2e469)
  - Forces fresh module downloads from git refs
  - Prevents cached module issues when module source refs are updated
  - Ensures latest module versions are always used
  - Critical for consuming consuming updated modules from `blaze-terraform-infra-core`

### Added

- **Provisioning Summary**: `01-provision-infra.yml` now generates a detailed infrastructure summary (ALB DNS, ECS Cluster, IAM Role).
  - Uses new outputs from `reusable-terraform.yml`.
- **Policy Deletion**: `reusable-pre-destroy-cleanup` now supports deleting IAM policies by ARN prefix.

### Fixed

- Terraform module caching issues that prevented updated modules from being used

### Added

- **ECR Orphan Import**: New composite action `actions/ecr-orphan-import`
  - Automatically detects ECR repositories that exist in AWS but are missing from Terraform state.
  - Generates `terraform import` blocks to facilitate state reconciliation.
  - Critical for adopting pre-existing ECR repositories into IaC management.

---

## v1.4.0 (2026-01-11)

### Added

**Cloudflare Pages Lifecycle Management**:

- **`cleanup-cloudflare-deployments`**: New action in `99-ops-utility.yml` to clean up old Cloudflare Pages deployments
  - Dual retention policy: by count (default: keep 5) OR age (default: 30 days)
  - Dry-run mode enabled by default for safety
  - Smart filtering keeps latest deployments and recent ones
  - Reduces storage costs and deployment clutter
- **`destroy-cloudflare-pages-bulk`**: New action for pattern-based bulk deletion of Pages projects
  - Pattern matching using shell globs (e.g., `blaze-*-test*-admin`)
  - Safety limit: maximum 10 projects per run
  - Requires special `BULK_DESTROY` confirmation to prevent accidents
  - Dry-run support for preview before deletion
  - Useful for cleaning up test/feature branch projects

**New Workflow Inputs**:

- `retention_count`: Number of deployments to keep (default: 5)
- `retention_days`: Delete deployments older than N days (default: 30)
- `dry_run`: Preview mode without making changes (default: true)
- `bulk_pattern`: Project name pattern for bulk operations

### Changed

**Enhanced Cloudflare Pages Destruction**:

- **Dynamic Configuration**: Replaced hardcoded `"blaze"` and `"thisisblaze"` with configuration outputs
  - Now uses `needs.configuration.outputs.namespace` and `needs.configuration.outputs.project_key`
  - Ensures naming consistency with creation logic in `02-deploy-app.yml`
  - Improves reusability across different projects

- **Enhanced Error Handling**: Added comprehensive HTTP status code handling
  - **HTTP 403 (Forbidden)**: Clear permission error messages with actionable advice
  - **HTTP 429 (Rate Limit)**: Automatic retry with exponential backoff (3 attempts: 2s → 4s → 8s)
  - **HTTP 404 (Not Found)**: Graceful handling for already-deleted projects
  - Improved debugging with detailed error context

### Security

**Safety Features**:

- All destructive Cloudflare operations default to dry-run mode
- Bulk operations require special `BULK_DESTROY` confirmation vs standard `DESTROY`
- Maximum 10 projects per bulk deletion to prevent accidental mass deletion
- Rate limiting protection prevents API abuse

## [1.3.3] - 2026-01-11)

### Added

**New Utility Workflows**:

- **`force-unlock.yml`**: Reusable workflow for unlocking Terraform state locks
  - Removes locks from DynamoDB table
  - Cleans up legacy .tflock files from S3
  - 10-minute timeout for billing protection
- **`debug-lock.yml`**: Reusable workflow for inspecting Terraform state locks
  - Displays lock details from DynamoDB
  - Lists all locks in the table
  - 10-minute timeout for billing protection

### Changed

**Timeout Protection Strategy**:

- Implemented proper billing protection across all reusable workflows
- Timeouts now set at the reusable workflow level (not caller level)
- All workflows verified to have appropriate timeout-minutes settings

**Existing Workflows Enhanced**:

- `fix-state-integrity.yml` - Already had 10min timeout
- `fix-cname-conflict.yml` - Already had 10min timeout
- `sync-secrets-from-ssm.yml` - Already had 10min timeouts on sync jobs
- `smart-dashboard.yml` - Verified timeout protection
- `nuke-cloudfront.yml` - Verified timeout protection
- `02-deploy-app.yml` - Multiple jobs with individual timeouts
- `01-provision-infra.yml` - 15min configuration timeout
- `99-ops-utility.yml` - 5-15min timeouts on all jobs
- `90-daily-health-check.yml` - 10min health-check timeout

### Security

**Billing Protection**:

- All workflows now have proper timeout protection
- Prevents runaway billing from hung workflows (default 6h → controlled timeouts)
- Estimated annual savings: $50-200 across all consuming repositories

## v1.2.0 (2026-01-09)

### Changed

- **Hardcoding Removal**: Replaced hardcoded "blaze" strings with dynamic `NAMESPACE` input in `calculate-config`.
- **Dynamic Naming**: Cluster and Bucket names now follow `${CLIENT}-${STAGE}-${NAMESPACE}` pattern.
- **Resource Importer**: `import.sh` now accepts explicit `CLUSTER_NAME` and `NAMESPACE` inputs.

## v1.1.0 (2026-01-08)

### Fixed

- **Critical:** Fixed cross-organization secret propagation in all workflows
  - Replaced `secrets: inherit` with explicit secret passing for cross-org compatibility
  - `01-provision-infra.yml`: Added `AWS_ROLE_ARN` to workflow_call secrets, fixed internal secret propagation to reusable-terraform
  - `02-deploy-app.yml`: Added NPM*TOKEN and all ECS runtime secrets (BLAZE_AUTH*_, BLAZE*CONNECTION_STRING, BLAZE_ELASTICSEARCH*_, BLAZE*FILES_S3*\*, etc.)
  - `90-daily-health-check.yml`: Added complete secret lists to drift-check jobs (Cloudflare, MongoDB, EC, ACM)
  - `00_setup_environment.yml`: Fixed git authentication ordering (Configure Git now runs AFTER setup-blaze)
  - Changed Terraform module ref from `main` to `dev` branch in preinit configuration

### Changed

- `01-provision-infra.yml`: Removed `destroy` option - all destroy operations now consolidated in `99-ops-utility.yml`

### Documentation

- Added comprehensive cross-org secret propagation guide
- Documented secret categories (Infrastructure, Build-time, ECS Runtime, Observability)

## v1.0.0 (2026-01-06)

- feat: add workflow validation (a79ca88)
- Initial release of blaze-actions repository
- 24 reusable workflows extracted
- 5 composite actions
