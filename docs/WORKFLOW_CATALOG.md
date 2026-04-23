**Last Updated**: 2026-04-21
**Owner**: Infrastructure Team

---

> [!TIP]
> **Status: SCALED (Multi-Tenant V2)**. Agent workflow instructions adhere strictly to the Phase 1 Foundation / Phase 2 Tenant orchestrated layers.


# Workflow Catalog

**Repository**: blaze-actions  
**Total Workflows**: 29 main + 20 reusable = 49 total  
**Version**: v2.4.6  
**Last Updated**: 2026-04-22

---

## Main Workflows (29)

> Note: Several new workflows (like cloud-specific `02-deploy-*` and `99-ops-*`) have been added. They follow standard input patterns.

### Infrastructure Provisioning

#### 00_setup_environment.yml

**Purpose**: Initial project bootstrap  
**Use Case**: First-time environment setup

**Inputs**:

- `environment` (required): Target environment (DEV-MINI/DEV/STAGE/PROD)
- `aws_region` (optional): AWS region (default: eu-west-1)

**What it does**:

- Creates GitHub OIDC provider
- Sets up Terraform state backend (AWS: S3 + DynamoDB | GCP: GCS | Azure: Blob Storage)
- Configures container registry (AWS: ECR | GCP: Artifact Registry | Azure: ACR)

**When to run**: Once per project/environment

---

#### 01-provision-infra.yml

**Purpose**: Infrastructure provisioning (network, app, third-party)  
**Use Case**: Create/update cloud infrastructure

**Inputs**:

- `cloud_provider` (choice): aws|gcp|azure (default: aws)
- `wif_audience` (optional): WIF Audience
- `environment` (required): DEV/DEV-MINI/STAGE/PROD/MULTI-SITE
- `project` (required): Project Identity (default: thisisblaze)
- `stack` (required): network|dedicated-network|db-pod-alpha|tenant-app|single-network|single-app|app|acm|third-party-mongodb|third-party-elastic
- `branch_name` (optional): Feature branch tag
- `apply` (boolean): Run terraform apply? (default: false)
- `destroy` (boolean): Teardown Stack (default: false)
- `force_destructive_reconcile` (boolean): Force reconcile (default: false)
- `terraform_version` (string): TF version (default: 1.9.0)
- `cluster_tier` (choice): MongoDB tier (auto|flex|M0|M10|M20|M30)
- `kibana_size` (choice): Elastic Kibana size (1g|2g)
- `enable_image_resize` (boolean): Enable CloudFront Image Resizing
- `enable_ec2` (boolean): Enable EC2 capacity providers (default: false)
- `api_launch_type` (choice): FARGATE or EC2
- `api_cpu_architecture` (choice): X86_64 or ARM64
- `frontend_launch_type` (choice): FARGATE or EC2
- `frontend_cpu_architecture` (choice): X86_64 or ARM64
- `workers_json` (string): JSON mapping payload for Dual-Engine background background workers

**What it does**:

- Runs Terraform init/plan/apply
- Provisions VPC, ECS clusters, ALB, databases
- Imports existing ACM certificates

**When to run**: Infrastructure changes

---

#### 02-deploy-app.yml

**Purpose**: Top-level multi-cloud application deployment dispatcher  
**Use Case**: Deploy Docker containers across AWS, GCP, and Azure

**Inputs**:

- `cloud_provider` (choice): aws|gcp|azure (default: aws)
- `environment` (required): dev-mini/dev/stage/prod
- `project` (required): Project identity (default: thisisblaze)
- `target_services` (required): Service filter (e.g., "api", "Blaze all")
- `branch_name` (optional): Feature branch tag
- `skip_build` (boolean): Skip Docker build?
- `deploy_services` (boolean): Deploy to ECS/Pages?
- `api_launch_type` (choice): `FARGATE` (default) or `EC2`
- `api_cpu_architecture` (choice): `X86_64` or `ARM64`
- `skip_stabilise` (boolean): Skip ECS stabilisation wait (for stress tests)

**What it does**: Delegates to `02-deploy-aws.yml`, `02-deploy-gcp.yml`, or `02-deploy-azure.yml`

**When to run**: Code deployments

---


### Testing & Validation

#### stress-test (decomposed into reusable-stress-test-*.yml)

**Purpose**: Full environment lifecycle testing has been split into composable reusable workflows:  
- `reusable-stress-test-provision.yml` — Provision phase  
- `reusable-stress-test-deploy.yml` — Deploy phase  
- `reusable-stress-test-verify.yml` — Verify phase  
- `reusable-stress-test-teardown.yml` — Teardown phase  

**Note**: `stress-test.yml` as a single file no longer exists. Use the reusable components via `/03-fire-stress-test` agent workflow.

---

#### 90-daily-health-check.yml

**Purpose**: Automated daily monitoring  
**Use Case**: Continuous health validation

**Inputs**:

- `environment` (required): Environment to check

**What it does**:

- Checks ECS service status
- Validates URLs and API health
- Reports Live Metrics (ECS Task Counts, Active Certs)
- Alerts on failures

**When to run**: Scheduled (cron) or manual

---

#### 05_ci_no_cloud.yml

**Purpose**: Fast local validation (no cloud credentials)  
**Use Case**: PR checks, local development

**What it does**:

- Terraform fmt/validate
- YAML linting
- Security scans (Trivy, tfsec)

**When to run**: On every PR/push

---

#### 10_security_scan.yml

**Purpose**: Comprehensive security auditing  
**Use Case**: Scheduled security reviews

**What it does**:

- Secret scanning (Gitleaks)
- Code analysis (Semgrep)
- Container scanning (Trivy)
- Infrastructure scanning (Terrascan, tfsec)

**When to run**: Daily or weekly scheduled

---


### Operations & Utilities

#### 99-ops-nuke.yml

**Purpose**: Multi-purpose operational tasks  
**Use Case**: Ad-hoc operations

**Operations**:

- `view-config`: Display environment configuration
- `list-stacks`: Show Terraform states
- `check-health`: Service health check
- `destroy-resources`: Safe destruction of infrastructure (defaulting to safe lambda cleanup)
- `cleanup-orphaned-lambdas`: Post-destroy lambda cleanup
- `nuke-environment`: Full environment teardown (Stop Services -> Destroy Resources -> Cleanup DNS)
- Manual interventions

**Inputs**:

- `environment` (required)
- `cloud_provider` (required): aws|gcp|azure
- `operation` (required)
- Additional operation-specific inputs

**When to run**: Operational tasks

---

#### sync-secrets-from-ssm.yml

**Purpose**: AWS SSM → GitHub Secrets synchronization  
**Use Case**: Propagate secrets from AWS to GitHub

**Inputs**:

- `environment` (required)
- `secret_prefix` (optional): SSM path prefix

**What it does**:

- Reads secrets from AWS SSM
- Updates GitHub repository secrets
- Supports MongoDB, Elastic credentials

**When to run**: After provisioning third-party services

---

#### smart-dashboard.yml

**Purpose**: Real-time infrastructure dashboard  
**Use Case**: Quick status overview

**Inputs**:

- `environment` (required)

**What it does**:

- Shows ECS cluster status
- Displays running services
- Resource utilization

**When to run**: As needed

---

#### lint-agent-workflows.yml

**Purpose**: Validate agent workflow markdown files on push to dev or PRs touching `.agent/workflows/**`  
**Trigger**: Automatic (push/PR)

**What it does**:

- Lints `.agent/workflows/` markdown for formatting issues
- Blocks PRs that break agent workflow syntax

**When to run**: Automatic CI gate

---

#### validate-workflows.yml

**Purpose**: Validate GitHub Actions workflow YAML syntax  
**Trigger**: Automatic on PR or push

**What it does**:

- Runs `actionlint` on all workflow files
- Prevents broken workflow YAML from merging

**When to run**: Automatic CI gate

---

#### update-changelog.yml

**Purpose**: Automated CHANGELOG.md generation on release tags  
**Trigger**: Automatic on tag push

**What it does**:

- Compiles commit history into CHANGELOG.md under the new version section
- Opens a PR with the generated changelog entry

**When to run**: Automatic on `git tag` push

---

### Debugging & Fixes

#### debug-lock.yml

**Purpose**: Terraform state lock debugging  
**Use Case**: Diagnose locked state

**Inputs**:

- `environment` (required)
- `stack` (optional): Specific stack

**What it does**:

- Shows DynamoDB lock table
- Displays lock details
- Suggests remediation

**When to run**: State lock issues

---

#### force-unlock.yml

**Purpose**: Force unlock Terraform state  
**Use Case**: Clear stuck locks (use carefully!)

**Inputs**:

- `environment` (required)
- `lock_id` (required): Lock ID from error message

**What it does**:

- Forces Terraform state unlock
- Clears DynamoDB lock entry

**When to run**: After confirming no other operations running

---

#### fix-state-integrity.yml

**Purpose**: Repair Terraform state issues  
**Use Case**: State corruption recovery

**Inputs**:

- `environment` (required)
- `stack` (required)
- `operation` (required): refresh|migrate|inspect

**What it does**:

- State refresh
- State migration
- State inspection

**When to run**: State integrity issues

---

#### fix-cname-conflict.yml

**Purpose**: Resolve Route53/ALB CNAME conflicts  
**Use Case**: DNS conflict resolution

**Inputs**:

- `environment` (required)
- `domain` (required): Conflicting domain

**What it does**:

- Identifies conflicting records
- Suggests fixes
- Optional auto-fix

**When to run**: DNS/CNAME conflicts

---





#### 02-deploy-app.yml
**Purpose**: Generic multi-cloud app deployment entrypoint. Routes to the appropriate cloud-specific deploy workflow (`02-deploy-aws`, `02-deploy-gcp`, `02-deploy-azure`) based on `cloud_provider` input.

---
#### 02-deploy-aws.yml
**Purpose**: AWS-specific deployment entrypoint. Orchestrates Docker build, ECR push, native ECS B/G update for API + frontend rolling for frontend. Called by `02-deploy-app.yml`.

---
#### 02-deploy-azure.yml
**Purpose**: Azure Container Apps deployment entrypoint. Builds image, pushes to ACR, rolls out new revision.

---
#### 02-deploy-gcp.yml
**Purpose**: GCP Cloud Run deployment entrypoint. Builds image, pushes to Artifact Registry, shifts traffic to new revision.

---
#### 02-deploy-pages.yml
**Purpose**: Cloudflare Pages deployment (DEV-MINI admin SPA). Builds Next.js admin and deploys to Cloudflare Pages project.

---
#### 99-ops-aws.yml
**Purpose**: AWS operational tasks — view config, list stacks, destroy resources, cleanup orphaned lambdas. Upgraded natively with CloudFront Active Telemetry to assure precise Surgical Garbage Collection during teardowns; explicitly hardened to gracefully manage zero-state environments (where zero CloudFront metadata exists) without crashing dry runs.

---
#### 99-ops-azure.yml
**Purpose**: Azure operational tasks — resource group inspection, Container App management, teardown.

---
#### 99-ops-cloudflare.yml
**Purpose**: Cloudflare DNS and zone operations — list records, delete conflicts, manage tunnel configs.

---
#### 99-ops-gcp.yml
**Purpose**: GCP operational tasks — Cloud Run inspection, Artifact Registry cleanup, project teardown.

---
#### 99-ops-nuke.yml
**Purpose**: Full environment nuke across any cloud provider. Inputs: `cloud_provider`, `environment`, `action` (default: nuke-environment), `skip_lambda_destroy` (boolean). Destroys all Terraform stacks in reverse dependency order.

---
#### 99-ops-utility.yml
**Purpose**: Unified operational utility dispatcher. Routes to `99-ops-aws`, `99-ops-gcp`, `99-ops-azure`, `99-ops-nuke`, `99-ops-terraform`, `99-ops-cloudflare`, or `99-ops-utility` based on `action` input. Supports: `manage-environment`, `destroy-resources`, `cleanup-orphaned-lambdas`, `cleanup-orphaned-buckets`, `nuke-environment`, `nuke-cloudfront`, `destroy-cloudflare-pages`, `destroy-cloudflare-pages-bulk`, `destroy-cloudflare-tunnel`, `sync-cloudflare-config`, `unlock-state`, `wipe-state`, `cleanup-dns`, `kill-workflows`.

---
#### 99-ops-terraform.yml
**Purpose**: Direct Terraform operations — plan, apply, destroy, state management for a specific stack without the full workflow pipeline.

---
#### 99-verify-azure.yml
**Purpose**: Azure environment health verification — checks Container App status, DNS resolution, HTTPS endpoints.

---

#### release.yml
**Purpose**: Semantic versioning release — bumps version tag, generates CHANGELOG entry, creates GitHub Release.

---
#### update-changelog.yml
**Purpose**: Automated CHANGELOG generation on release tag push. Opens a PR with the compiled changelog.

---
#### reusable-provision-db-users.yml
**Purpose**: ~~Provision MongoDB database users for a given project/environment.~~ **DEPRECATED for multi-site environments (2026-04-14).** Superseded by the `enable_db_users` flag in `multi-site-app` module (v2.3.3+), which provisions Atlas users automatically per `project_key` in the `sites` map when `01c` runs. Still used for legacy single-tenant stacks.

---

## Reusable Workflows (19)

These are called by main workflows, not directly by users.

---

### reusable-terraform.yml

**Purpose**: Core Terraform operations (init/plan/apply)  
**Inputs**: tf_dir, bucket, state_key, apply, destroy  
**Outputs**: terraform_outputs

---

### reusable-docker-build.yml

**Purpose**: Docker image build and push  
**Inputs**: service_name, image_tag, dockerfile_path  
**Outputs**: image_uri

---

### reusable-ecs-deploy.yml

**Purpose**: ECS service deployment (Fargate or EC2)  
**Inputs**: cluster_name, service_name, image_uri, launch_type, cpu_architecture  
**Outputs**: deployment_status

---

### reusable-ecs-service-management.yml

**Purpose**: ECS service operations (start/stop/scale)  
**Inputs**: cluster_name, action, service_name, desired_count  
**Outputs**: service_status

---

### reusable-pre-destroy-cleanup.yml

**Purpose**: Essential cleanup before infrastructure destroy to prevent hangs.
**Use Case**: Removes EC2 Capacity Providers, Launch Templates, and Logs.
**Inputs**: cluster_name, aws_region, force_delete  
**Outputs**: cleanup_status

---

### reusable-terraform-operations.yml

**Purpose**: Simplified Terraform operations wrapper  
**Inputs**: action, tf_dir, bucket, state_key  
**Outputs**: outputs

---



#### reusable-azure-multi-site-deploy.yml
**Purpose**: Azure Container Apps multi-site deployment. Iterates site definitions, updates container app revisions per site.

---
#### reusable-cloudrun-deploy.yml
**Purpose**: GCP Cloud Run service update. Deploys new image URI to a Cloud Run service and shifts traffic.

---
#### reusable-container-app-deploy.yml
**Purpose**: Azure Container App revision deployment. Creates new revision with updated container image.

---
#### reusable-gcp-multi-site-deploy.yml
**Purpose**: GCP multi-site Cloud Run deployment orchestrator. Loops through site configs and delegates to `reusable-cloudrun-deploy`.

---
#### reusable-multi-site-deploy.yml
**Purpose**: AWS multi-site ECS deployment orchestrator. Iterates site configs, triggers per-site native ECS rolling updates.

---
#### reusable-noop.yml
**Purpose**: No-op placeholder workflow. Used as a safe target for conditional `needs:` chains when a step is skipped.

---
#### reusable-verify-aws.yml
**Purpose**: AWS environment health verification. Checks ECS service counts, ALB target health, and HTTPS endpoint responses.

---
#### reusable-verify-azure.yml
**Purpose**: Azure environment health verification. Validates Container App running state and HTTPS endpoint responses.

---
#### reusable-verify-gcp.yml
**Purpose**: GCP environment health verification. Validates Cloud Run serving state and HTTPS endpoint responses.

---
#### reusable-stress-test-provision.yml
**Purpose**: Stress test provision phase. Runs `01-provision-infra` for network, app, and third-party stacks. Uses `project_key` from `calculate-config` — no hardcoded project names.

---
#### reusable-stress-test-deploy.yml
**Purpose**: Stress test deploy phase. Calls `02-deploy-app.yml` with the calculated project config. Uses `project_key` from `calculate-config`.

---
#### reusable-stress-test-teardown.yml
**Purpose**: Stress test teardown phase. Destroys all stacks in reverse order after a stress test cycle.

---
#### reusable-stress-test-verify.yml
**Purpose**: Stress test verification phase. Runs URL health checks and ECS service validation after deployment.

---
## Quick Reference

| Workflow                | Common Use             | Typical Runtime |
| :---------------------- | :--------------------- | :-------------- |
| `00_setup_environment`  | First-time setup       | 5-10 min        |
| `01-provision-infra`    | Infrastructure changes | 10-20 min       |
| `02-deploy-app`         | Code deployments       | 5-10 min        |
| `stress-test`           | Release validation     | 30-40 min       |
| `99-ops-nuke`        | Ad-hoc operations      | 2-5 min         |
| `90-daily-health-check` | Daily monitoring       | 2-5 min         |

---

---

## Version History

**v2.4.6** (2026-04-22):
- Deep CI/CD maintenance sync: Updated workflow catalog, resolved all references to renamed workflows (e.g. `04-deploy-multi-site` to `02-deploy-app`), removed non-existent workflows (`deploy-site`, `nuke-cloudfront`), and aligned versions to `v2.4.6`.

**v2.1.62** (2026-04-21):
- Added `workers_json` input to `01-provision-infra.yml` — routes Plan 146 Dual-Engine background worker config (SQS/Lambda fast + Fargate/cron heavy) into Terraform.
- Committed `workers.tf` + updated `variables.tf` in `blaze-terraform-infra-core` `multi-site-tenant-app` module — actual IaC for Plan 146 now live.
- WORKFLOW_CATALOG total count corrected: 33 main + 20 reusable = 53 total.
- Added `02-deploy-app.yml` as a documented first-class entry (was missing despite being a major dispatcher).
- Timestamps updated across all 3 repos to 2026-04-21.

**v2.1.60** (2026-04-17):
- Replaced destructive `terraform state rm` logic in `01-provision-infra.yml` with secure **Smart Import** for Lambda@Edge and WAF to prevent `ResourceConflictException` (HTTP 409) during dirty pipeline redeployments.
- Hardened `cleanup-orphaned-lambdas` logic in `99-ops-aws.yml` with **Surgical Telemetry**. The script now physically queries CloudFront's `LambdaFunctionAssociations` to perfectly skip active bindings, eliminating AWS blocking errors from the logs.
- Re-architected DNS Teardown: Re-enabled `nuke-cleanup-dns` during nuke routines to purge robust Stage records natively, saving downstream CloudFront distribution 409 collisions.

**v2.1.59** (2026-04-16):
- Global standardization to `@v2.1.59` to resolve split-brain drift tagging.
- Enhanced `cleanup-orphaned-lambdas` with wildcard matching for multi-tenant namespaces.
- Introduced `skip_lambda_destroy` parameter to `99-ops-nuke.yml`.
- Added missing `02-deploy-app.yml` and `99-ops-utility.yml` entries to catalog.
- Total workflow count corrected to 56 (37 main + 19 reusable).

**v2.1.58** (2026-04-14):

- Added `01g-provision-db-pod.yml` — env-level Atlas DB pod workflow for multi-site
- `reusable-provision-db-users.yml` deprecated for multi-site environments
- Per-site Atlas DB user provisioning now automatic via `multi-site-app` v2.3.3+ `module.db_tenant`
- Atlas IP access list security: locked to VPC CIDR when peering active (vpc-peering v2.3.4)
- `90-daily-health-check.yml` bumped to `@v2.1.59` across all repos

**v1.5.0** (2026-02-27):

- Native ECS Blue/Green (no CodeDeploy)
- DEV-MINI environment (Cloudflare Tunnel only)
- Admin SPA: S3 sync + CloudFront invalidation added to `02-deploy-app`
- DEV mirrors STAGE (full CloudFront + WAF + ALB + Image Resize)
- `deploy-site.yml` blue-green migrated from CodeDeploy to Native ECS B/G

**v1.4.0-workflow-consolidation** (2026-02-17):

- Ops Utility expansion: `cleanup-dns`, `nuke-cloudfront`
- Stress Test Wrapper Pattern

**v1.2.0-multi-cloud-foundation** (2026-02-16):

- Multi-cloud foundation (AWS/GCP/Azure)
- 24 workflows, 7 reusable
- Hub & Spoke architecture

---

**Last Updated**: 2026-04-22  
**Maintainer**: thisisblaze/blaze-actions  
**License**: Apache 2.0
