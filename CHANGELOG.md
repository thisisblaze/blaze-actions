# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.3.0 (2026-01-11)

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
