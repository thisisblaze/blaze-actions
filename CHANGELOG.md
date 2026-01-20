# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
