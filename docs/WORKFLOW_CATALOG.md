**Last Updated**: 2026-04-07
**Owner**: Infrastructure Team

---

# Workflow Catalog

**Repository**: blaze-actions  
**Total Workflows**: 53 (32 main + 21 reusable)  
**Version**: v2.1.13  
**Last Updated**: 2026-04-07

---

## Main Workflows (31)

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

- `environment` (required): DEV-MINI/DEV/STAGE/PROD
- `project` (optional): Project key (default: thisisblaze)
- `cloud_provider` (required): aws|gcp|azure (default: aws)
- `stack` (required): network|acm|tunnel|app|account-settings|third-party-mongodb|third-party-elastic
- `branch_name` (optional): Feature branch tag
- `apply` (boolean): Run terraform apply? (default: false)
- `cluster_tier` (optional): MongoDB tier (auto|M2|M10|M20|M30)
- `kibana_size` (optional): Elastic Kibana size (1g|2g)
- `is_paused` (boolean): Pause MongoDB cluster?
- `enable_ec2` (boolean): Enable EC2 capacity providers (default: false)

**What it does**:

- Runs Terraform init/plan/apply
- Provisions VPC, ECS clusters, ALB, databases
- Imports existing ACM certificates

**When to run**: Infrastructure changes

---

#### 02-deploy-app.yml

**Purpose**: Application deployment (ECS, Cloud Run, or Container Apps)
**Use Case**: Deploy Docker containers + Admin SPA (S3/CloudFront for AWS)

**Inputs**:

- `environment` (required): dev-mini/dev/stage/prod
- `cloud_provider` (required): aws|gcp|azure (default: aws)
- `target_services` (required): Service filter (e.g., "api", "Blaze all")
- `branch_tag` (optional): Feature branch tag
- `skip_build` (boolean): Skip Docker build?
- `build_all` (boolean): Force build all services?
- `api_launch_type` (choice): API launch type — `FARGATE` (default) or `EC2`
- `api_cpu_architecture` (choice): API CPU arch — `X86_64` (default) or `ARM64`

**What it does**:

- Builds Docker images (multi-arch: AMD64 + ARM64)
- Pushes to registry (ECR/AR/ACR based on `cloud_provider`)
- Updates service definitions
- Deploys to target platform:
  - **AWS API**: **Native ECS Blue/Green** (no CodeDeploy)
  - **AWS Frontend**: Rolling deployment
  - **AWS Admin SPA**: S3 sync + CloudFront cache invalidation (DEV/STAGE/PROD only; DEV-MINI uses Cloudflare Pages)
  - **GCP**: Cloud Run revision rollout
  - **Azure**: Container Apps revision rollout

**When to run**: Code deployments

---

### Testing & Validation

#### 08-stress-test-suite.yml

**Purpose**: Full environment lifecycle stress testing  
**Use Case**: Validate complete infrastructure + deployment pipeline

**Inputs**:

- `environment` (required): dev-mini/dev/stage/prod
- `mode` (required): mini|standard|full-circle|quick-test|destroy-only
- `branch_tag` (optional): Feature branch tag
- `include_third_party` (boolean): Test MongoDB/Elastic?
- `preserve_host` (boolean): Skip network destroy/provision?

**What it does**:

- Complete lifecycle: provision → deploy → verify
- URL health checks, service validation
- Optional cleanup post-test

**When to run**: Release validation, CI/CD gates

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

#### terraform-tests.yml

**Purpose**: Terraform module testing  
**Use Case**: Module validation

**What it does**:

- Tests Terraform modules
- Validates outputs
- Checks formatting

**When to run**: Module changes

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

**Purpose**: Validate `.agent/workflows/*.md` YAML frontmatter on every push/PR  
**Use Case**: CI gate ensuring agent workflow files have valid `description:` metadata

**Trigger**: `push` (main), `pull_request` (paths: `.agent/**`)

**What it does**:

- Checks out repository
- Lints YAML frontmatter in all agent workflow markdown files
- Fails CI if `description:` is missing or malformed

**When to run**: Automatic — triggered on every PR touching `.agent/**`

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

#### nuke-cloudfront.yml

**Purpose**: CloudFront distribution cleanup  
**Use Case**: Remove orphaned distributions

**Inputs**:

- `distribution_id` (optional): Specific distribution
- `confirm` (boolean): Require confirmation

**What it does**:

- Lists CloudFront distributions
- Disables and deletes
- Cleans up orphaned resources

**When to run**: CloudFront cleanup needed

---



### Newly Added Main Workflows

#### 02-deploy-aws.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 02-deploy-azure.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 02-deploy-gcp.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 02-deploy-pages.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-ops-aws.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-ops-azure.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-ops-cloudflare.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-ops-gcp.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-ops-nuke.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-ops-terraform.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### 99-verify-azure.yml
**Purpose**: Refer to newer cloud-specific operation

---
#### deploy-azure-site.yml
**Purpose**: Deploy a single site to Azure Container Apps (multi-site architecture)

---
#### deploy-gcp-site.yml
**Purpose**: Deploy a single site to GCP Cloud Run (multi-site, `reusable-gcp-multi-site-deploy.yml` caller)
**Inputs**: `site_key`, `environment`, `image_tag`, `cloud_provider`

---
#### deploy-site.yml
**Purpose**: Deploy a single site (AWS ECS multi-site) — calls `reusable-multi-site-deploy.yml`

---
#### release.yml
**Purpose**: Auto-tag and create GitHub Release on main push — bumps semver patch

---
#### update-changelog.yml
**Purpose**: Automated changelog update on merge to main

---
#### validate-workflows.yml
**Purpose**: Lint and validate all workflow YAML files in the repository

---
## Reusable Workflows (19)

These are called by main workflows, not directly by users.

### reusable-calculate-config.yml

**Purpose**: Configuration loading and calculation  
**Inputs**: environment, terraform_stack, branch_tag, project  
**Outputs**: All config values (bucket, state_key, aws_region, etc.)

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

### reusable-provision-db-users.yml

**Purpose**: Provision database users post-infrastructure deployment  
**Use Case**: Create app-level DB users in RDS/MongoDB after Terraform apply  
**Inputs**: `environment`, `project`, `cloud_provider`, `db_type`  
**Outputs**: `users_created`

---

### Newly Added Reusable Workflows

#### reusable-azure-multi-site-deploy.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-cloudrun-deploy.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-container-app-deploy.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-gcp-multi-site-deploy.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-multi-site-deploy.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-noop.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-verify-aws.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-verify-azure.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-verify-gcp.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-stress-test-provision.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-stress-test-deploy.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-stress-test-teardown.yml
**Purpose**: Reusable component for specific cloud or test phase

---
#### reusable-stress-test-verify.yml
**Purpose**: Reusable component for specific cloud or test phase

---
## Quick Reference

| Workflow                  | Common Use             | Typical Runtime |
| :------------------------ | :--------------------- | :-------------- |
| `00_setup_environment`    | First-time setup       | 5-10 min        |
| `01-provision-infra`      | Infrastructure changes | 10-20 min       |
| `02-deploy-app`           | Code deployments       | 5-10 min        |
| `08-stress-test-suite`    | Release validation     | 30-40 min       |
| `99-ops-utility`          | Ad-hoc operations      | 2-5 min         |
| `90-daily-health-check`   | Daily monitoring       | 2-5 min         |
| `lint-agent-workflows`    | Agent workflow CI gate | <1 min          |

---

## Version History

**v2.1.13** (2026-04-07):

- `reusable-terraform.yml`: Restored GH_PAT as primary git auth for module cloning (DEPLOY_KEY > GH_PAT > github.token)
- `01-provision-infra.yml`: Added `destroy != true` guard on zombie importer step
- `90-daily-health-check.yml`: Bumped all pins to `v2.1.13` (parity with blaze-template-deploy)
- Catalog: Removed deleted `stress-test.yml` and `check-stack-exists.yml`; added `deploy-gcp-site.yml`, `lint-agent-workflows.yml`, `reusable-provision-db-users.yml`

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

**Last Updated**: 2026-04-07  
**Maintainer**: thisisblaze/blaze-actions  
**License**: Apache 2.0
