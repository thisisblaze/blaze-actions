# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
