**Last Updated**: 2026-06-13
**Owner**: Infrastructure Team

---

> [!TIP]
> **Status: SCALED (Multi-Tenant V2)**. Agent workflow instructions adhere strictly to the Phase 1 Foundation / Phase 2 Tenant orchestrated layers.


# Workflow Catalog

**Repository**: blaze-actions  
**Total Workflows**: 30 main + 24 reusable = 54 total  
**Version**: v2.5.7  
**Last Updated**: 2026-06-13

---

## Main Workflows (30)

> Note: Several new workflows (like cloud-specific `02-deploy-*` and `99-ops-*`) have been added. They follow standard input patterns.

### Infrastructure Provisioning

#### 00_setup_environment.yml

**Purpose**: Initial project bootstrap  
**Use Case**: First-time environment setup

**Inputs**:

- `cloud_provider` (optional): 
- `elasticsearch_tag` (optional): 
- `environment` (required): 
- `images` (optional): 
- `kibana_tag` (optional): 
- `mongo_tag` (optional): 
- `task` (optional): 
- `terraform_version` (optional): 
- `tunnel_tag` (optional): 
- `wif_audience` (optional):
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

- `api_cpu_architecture` (optional): 
- `api_launch_type` (optional): 
- `apply` (optional): 
- `azure_client_id_rev` (optional): 
- `azure_subscription_id_rev` (optional): 
- `azure_tenant_id_rev` (optional): 
- `branch_name` (optional): 
- `cloud_provider` (optional): 
- `cluster_tier` (optional): 
- `destroy` (optional): 
- `enable_ec2` (optional): 
- `enable_image_resize` (optional): 
- `enable_tunnel` (optional): 
- `enable_vpc_peering` (optional): Enable Atlas VPC peering (Plan 135). Requires non-flex cluster (M10+). Passed as TF_VAR_enable_vpc_peering.
- `environment` (required): 
- `force_destructive_reconcile` (optional): 
- `frontend_cpu_architecture` (optional): 
- `frontend_launch_type` (optional): 
- `kibana_size` (optional): 
- `project` (required): 
- `stack` (required): 
- `terraform_version` (optional): 
- `wif_audience` (optional): 
- `workers_json` (optional): Background Workers Configuration (JSON String)
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

- `api_cpu_architecture` (optional): 
- `api_launch_type` (optional): 
- `azure_client_id_rev` (optional): 
- `azure_subscription_id_rev` (optional): 
- `azure_tenant_id_rev` (optional): 
- `branch_name` (optional): 
- `build_images` (optional): 
- `cloud_provider` (optional): 
- `deploy_services` (optional): 
- `environment` (required): 
- `frontend_cpu_architecture` (optional): 
- `frontend_launch_type` (optional): 
- `override_image_tag` (optional): 
- `project` (required): 
- `skip_stability_wait` (optional): Set to 'true' to skip ECS stabilisation wait (for stress tests)
- `smoke_test_url` (optional): URL to hit for post-deploy smoke test
- `target_services` (optional): 
- `wif_audience` (optional):
**What it does**: Delegates to `02-deploy-aws.yml`, `02-deploy-gcp.yml`, or `02-deploy-azure.yml`

**When to run**: Code deployments

---


### Testing & Validation

#### terraform-tests.yml

**Purpose**: Run integration tests that create real AWS resources
**Use Case**: CI Terraform validation

**Inputs**:

- `run_integration` (optional): Run integration tests
- `scan_path` (optional): Path to scan for Terraform modules/stacks
**What it does**:
- Creates AWS resources for integration testing

**When to run**: On PRs modifying modules

---

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

- `cloud_provider` (optional): 
- `environment` (optional):
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

- Pin Guard (fails on active `@dev` references in workflows/actions)
- Workflow Linting (actionlint)
- Environment Config Validation (validates JSON configurations against schema)
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
- Code analysis (SAST Semgrep)
- Dependency Scan (Trivy filesystem) & Lockfile Validation
- IaC Security Scan (Trivy config scan)
- Repository Integrity (OSSF Scorecard)
- Infrastructure scanning (Terrascan, tfsec)

**When to run**: Daily or weekly scheduled

---


### Operations & Utilities

#### 99-ops-utility.yml

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

- `action` (required): 
- `branch_tag` (optional): 
- `bulk_pattern` (optional): 
- `cloud_provider` (optional): 
- `confirmation` (optional): for destructive actions on **manual dispatch**, must be the target-scoped keyword `DESTROY-<environment>-<stack>` (99-ops-terraform/utility) or `DESTROY-<environment>-<cloud_provider>` (99-ops-nuke); programmatic `workflow_call` accepts `DESTROY`/`EXECUTE` (plan 163 O3)
- `desired_count` (optional): 
- `dist_id` (optional): 
- `dry_run` (optional): 
- `environment` (optional): 
- `manage_action` (optional): 
- `retention_count` (optional): 
- `retention_days` (optional): 
- `run_id` (optional): 
- `skip_lambda_destroy` (optional): 
- `stack` (optional):
**When to run**: Operational tasks

---

#### sync-secrets-from-ssm.yml

**Purpose**: AWS SSM → GitHub Secrets synchronization  
**Use Case**: Propagate secrets from AWS to GitHub

**Inputs**:

- `environment` (required): Target Environment
- `services` (optional): Services to sync
- `sync_github` (optional): Sync to GitHub Secrets?
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

#### find-zombie.yml

**Purpose**: Find Zombie CloudFront
**Use Case**: CNAME search

**Inputs**:

- `target_cname` (required): CNAME to search for
**What it does**:
- Finds zombie cloudfront distributions

**When to run**: As needed

---

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
- `stack` (required)
- `reason` (required on manual dispatch — recorded in the audit trail; plan 163 O4)
- `lock_id` (required): Lock ID from error message

**What it does**:

- Forces Terraform state unlock
- Clears DynamoDB lock entry
- Writes a durable audit record (run log + job summary): actor, env, stack, lock id, reason, UTC timestamp (plan 163 O4)

**When to run**: After confirming no other operations running

---

#### fix-state-integrity.yml

**Purpose**: Repair Terraform state issues  
**Use Case**: State corruption recovery

**Inputs**:

- `dynamodb_table` (required): DynamoDB Lock Table Name
- `environment` (required): Environment (DEV/STAGE/PROD)
- `state_key_path` (required): S3 Key to Clean (e.g., infra/.../cloudflare.tfstate)
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

- `dist_id` (required): Distribution ID (or Domain Name) to strip aliases from
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

**Key inputs** (passed through from `02-deploy-app.yml`):
- `php_version` (optional): PHP version to set up before build (e.g. `"8.4"`). If set, uses `shivammathur/setup-php@v2`.
- `build_command` (optional): Shell command to run before image packaging (e.g. `composer install`).
- `api_launch_type` (choice): `FARGATE` (default) or `EC2`
- `api_cpu_architecture` (choice): `X86_64` or `ARM64`
- `smoke_test_url` (optional): URL to hit for post-deploy smoke test

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
**Inputs**: apply, aws_region, azure_client_id_rev, azure_subscription_id_rev, azure_tenant_id_rev, bucket, build_sharp, cloud_provider, destroy, detect_drift, enable_vpc_peering, environment, lock_table, orphan_lambda, orphan_lambda_namespace, pre_apply_script, sleep_seconds, split_apply, split_targets, stack_id, state_key, terraform_version, tf_dir, tf_vars, wif_audience
**Outputs**: terraform_outputs

---

### reusable-docker-build.yml

**Purpose**: Docker image build and push  
**Inputs**: aws_region, azure_client_id_rev, azure_registry_server, azure_subscription_id_rev, azure_tenant_id_rev, build_args, cloud_provider, context, display_name, dockerfile, environment, gcp_project_id, gcp_region, image_name, image_tag, platforms, wif_audience
**Outputs**: image_uri

---

### reusable-ecs-deploy.yml

**Purpose**: ECS service deployment (Fargate or EC2)  
**Inputs**: api_ap_id, aws_region, branch_name, client_key, cloud_platform, cloud_provider, config_environment, cpu_architecture, dfp_network_id, domain_root, efs_id, elasticsearch_endpoint, environment, es_ap_id, gtm_id, image_tag, launch_type, mongo_ap_id, namespace, ns_id, project_key, registry, s3_bucket, s3_public_url, service_name, skip_stability_wait, stage_key
**Outputs**: deployment_status

---

### reusable-ecs-service-management.yml

**Purpose**: ECS service operations (start/stop/scale)  
**Inputs**: action, aws_region, cloud_provider, cluster_name, desired_count, environment, service_name, stage_filter
**Outputs**: service_status

---

### reusable-pre-destroy-cleanup.yml

**Purpose**: Essential cleanup before infrastructure destroy to prevent hangs.
**Use Case**: Removes EC2 Capacity Providers, Launch Templates, CloudFront, Target Groups, and Logs surgically.
**Inputs**: aws_region, cloud_provider, cluster_name, dry_run, environment, force_delete, stack_id, stage_filter, target_stack, wif_audience
**Outputs**: cleanup_status

---

### reusable-terraform-operations.yml

**Purpose**: Simplified Terraform operations wrapper  
**Inputs**: action, aws_region, azure_client_id_rev, azure_subscription_id_rev, azure_tenant_id_rev, branch_name, bucket, client_key, cloud_platform, domain_root, environment, lock_table, namespace, project_key, stage_key, state_key, terraform_vars, tf_dir, wif_audience, working_directory
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

#### reusable-elastic-beanstalk-deploy.yml
**Purpose**: Packages application code and pushes an Application Version to AWS Elastic Beanstalk via S3. Supports optional PHP setup and pre-package build commands.

**Inputs**:
artifact_registry_url, environment, gcp_project_id, gcp_region, image_repository, image_tag, multi_revision, service_name, shift_strategy, site_key
- `application_name` (required): Elastic Beanstalk application name
- `environment_name` (required): Elastic Beanstalk environment name
- `aws_region` (optional): AWS region (default: `eu-west-1`)
- `s3_bucket` (optional): S3 bucket for bundle upload; uses EB default if omitted
- `build_command` (optional): Shell command to run before zipping artifact (e.g. `composer install --no-dev`)
- `php_version` (optional): PHP version to set up before build (e.g. `"8.4"`)

**Secrets**: `AWS_ROLE_ARN` (required)

**What it does**: Runs optional PHP setup → optional build command → zips source (excluding `.git`, `.github`, `.agent`, `tests`) → uploads bundle to S3 → creates EB Application Version → deploys to EB environment → (optionally) writes version label to SSM Parameter Store.

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
#### reusable-backup-snapshot.yml
**Purpose**: Multi-service backup snapshot workflow (Plan 151 L14 + Plan 152 Phase 4). Runs four sequential backup jobs: RDS MySQL snapshot, S3 CRR sync verification, SSM parameter inventory export, and DocumentDB cluster snapshot.

**Inputs**:
aws_region, azure_acr_name, branch_tag, client_key, cloud_region, cluster_name, domain_root, environment, gcp_project_id, namespace, project_key, stage_key, target_type, wif_audience
- `aws_region` (optional): AWS region (default: `eu-west-1`)

**Secrets**: `AWS_ROLE_ARN` (required)

**What it does**: Creates an RDS manual snapshot → Verifies S3 replication sync → Exports SSM parameter inventory → Creates a DocumentDB cluster snapshot. Each job is idempotent and named by date to prevent collisions.

**Caller**: `98-backup-snapshot.yml`

---
#### reusable-dev-sleep-schedule.yml
**Purpose**: FinOps dev environment sleep/wake schedule (Plan 151 L4). Scales down ECS services to 0 and stops RDS in the correct dependency order (ECS first, then RDS), or reverses the order for wake-up (RDS first, then ECS).

**Inputs**:
action, aws_region, cluster, db_instance, desired_count_wake, rds_wait_minutes, services
- `action` (required): `sleep` or `wake`
- `aws_region` (optional): AWS region (default: `eu-west-1`)

**Secrets**: `AWS_ROLE_ARN` (required)

**What it does**: `sleep` — gracefully stops all ECS services (waits for stability), then stops the RDS instance. `wake` — starts RDS, waits for available state, then scales ECS services back to 1. Achieves ~55% compute cost saving on non-production environments.

**Caller**: `04-dev-sleep-schedule.yml` (scheduled Mon–Fri: sleep 20:03 UTC, wake 06:50 UTC)

---
#### reusable-ecs-health-snapshot.yml
**Purpose**: Single-click ECS incident health snapshot (Plan 151 L7). Produces a consolidated report covering ECS service states, container health checks, stopped task failure reasons, and endpoint availability.

**Inputs**:
aws_region, cluster, endpoint, environment, log_group_prefix, services, tail_lines
- `aws_region` (optional): AWS region (default: `eu-west-1`)
- `endpoint_url` (optional): HTTPS endpoint to probe for availability

**Secrets**: `AWS_ROLE_ARN` (required)

**What it does**: Queries ECS cluster → Lists all services and running/stopped tasks → Extracts `stoppedReason` for failed containers → Tails CloudWatch logs for recent errors → Probes the endpoint URL and reports HTTP status. Outputs a structured markdown summary as a GitHub Step Summary.

**Caller**: `03-ecs-health-snapshot.yml`

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

**v2.2.3** (2026-06-02):
- AI governance: Added `AGENTS.md` (root) and `.github/agents/` directory with `@maintainer` and `@sre` custom agent persona definitions across all 4 repos.
- Upgraded `.github/copilot-instructions.md` across all 4 repos from a stub to a substantive guide.
- Abstracted all hardcoded `blaze-template-deploy` references in shared parent repo `CLAUDE.md` files to generic "Tenant Implementation Repo" terminology — enabling clean multi-tenant reuse.
- Added `docs/operations/nuke_environment_runbook.md` (comprehensive 5-stage environment teardown manual).
- **Workflow count corrected**: 30 main + 24 reusable = 54 total (previous count of 38 main was incorrect — includes only root-level non-reusable workflows).

**v2.2.2** (2026-05-31):
- Platform-Agnostic Workflow Optimization (Plan 154 Phase 1–5): Self-healing orchestrator loop, 5-Role CLAUDE.md model, IDE parity.
- Bumped GHA self-refs `v2.1.74` → `v2.2.2`, Terraform pins → `v2.6.9`.

**v2.1.80** (2026-05-09):
- Plan 151 + Plan 152 delivery: Added 3 new reusable workflows to catalog (`reusable-backup-snapshot`, `reusable-dev-sleep-schedule`, `reusable-ecs-health-snapshot`).
- Bumped all action pins `@v2.1.74` → `@v2.1.80` across all 3 repos (Engine 8 parity restored).
- Fixed `@dev` refs in `03-ecs-health-snapshot.yml` and `04-dev-sleep-schedule.yml` callers → `@v2.1.80`.
- Total workflow count corrected: 30 main + 24 reusable = 54 total.
- **2026-05-12**: Added `/12-best-practice-audit` agent workflow + `docs/learning/REFERENCE_SOURCE_LIBRARY.md` (5-domain, 9 priority checks, knowledge base freshness step).

**v2.1.77** (2026-05-08):
- Deep CI/CD maintenance sync: Added `php_version` + `build_command` inputs to `02-deploy-aws.yml` catalog entry.
- Moved dangling `reusable-elastic-beanstalk-deploy.yml` table row into proper Reusable section with full input documentation.
- Fixed total workflow count to 59 (38 main + 21 reusable).

**v2.5.7** (2026-05-02):
- Deep CI/CD maintenance sync: Updated workflow catalog with missing workflows (e.g. `reusable-elastic-beanstalk-deploy.yml`)
- Hardened elastic-beanstalk module deployment across CI environments by explicitly setting resource to prevent inconsistent final plan bug.
- Bumped global versions to `@v2.5.7` to definitively seal the pipeline from referencing stale refs.

**v2.1.74 & v2.4.8** (2026-04-24):
- Deep CI/CD maintenance sync: Resolved checkengines workflow parity errors.
- Hardened teardown scripts: Enforced native `jq` type safety (`type=="array"`) to elegantly handle AWS CLI `null` capacityProviders during ECS cluster deletion.
- ALB naming collision fix: Enforced strict `trimsuffix("-")` to prevent AWS validation errors when 32-character project prefixes truncate at a hyphen.
- Global Tag Normalization: Systematically bumped all nested internal workflow tags to `v2.1.74` and terraform core refs to `v2.4.8` to definitively seal the pipeline from referencing stale, buggy logic during the stress tests.

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

## Agent Intelligence

| Resource | Description |
| :--- | :--- |
| [`docs/learning/REFERENCE_SOURCE_LIBRARY.md`](learning/REFERENCE_SOURCE_LIBRARY.md) | 5-domain reference library: GH Actions patterns, OIDC, Terraform CI/CD, deployment, access control. Cross-links all `docs/knowledge/` smart fixes. |
| [`.agent/workflows/12-best-practice-audit.md`](../.agent/workflows/12-best-practice-audit.md) | Monthly read-only CI/CD audit workflow. 9 priority checks + knowledge base freshness step. |

---

**Last Updated**: 2026-06-13  
**Maintainer**: thisisblaze/blaze-actions  
**License**: Apache 2.0
