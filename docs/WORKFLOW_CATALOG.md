**Last Updated**: 2026-02-08
**Owner**: Infrastructure Team

---

# Workflow Catalog

**Repository**: blaze-actions  
**Total Workflows**: 24 (17 main + 7 reusable)  
**Version**: v1.1.0-hybrid-ecs  
**Last Updated**: 2026-02-09

---

## Main Workflows (17)

### Infrastructure Provisioning

#### 00_setup_environment.yml

**Purpose**: Initial project bootstrap  
**Use Case**: First-time environment setup

**Inputs**:

- `environment` (required): Target environment (DEV/STAGE/PROD)
- `aws_region` (optional): AWS region (default: eu-west-1)

**What it does**:

- Creates GitHub OIDC provider
- Sets up Terraform state backend (S3 + DynamoDB)
- Configures ECR for Docker images

**When to run**: Once per project/environment

---

#### 01-provision-infra.yml

**Purpose**: Infrastructure provisioning (network, app, third-party)  
**Use Case**: Create/update cloud infrastructure

**Inputs**:

- `environment` (required): DEV/STAGE/PROD
- `project` (optional): Project key (default: thisisblaze)
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

**Purpose**: Application deployment to ECS  
**Use Case**: Deploy Docker containers

**Inputs**:

- `environment` (required): dev/stage/prod
- `target_services` (required): Service filter (e.g., "api", "Blaze all")
- `branch_tag` (optional): Feature branch tag
- `skip_build` (boolean): Skip Docker build?
- `build_all` (boolean): Force build all services?
- `api_launch_type` (choice): API launch type — `FARGATE` (default) or `EC2`
- `api_cpu_architecture` (choice): API CPU arch — `X86_64` (default) or `ARM64`

**What it does**:

- Builds Docker images (multi-arch: AMD64 + ARM64)
- Pushes to ECR
- Updates ECS task definitions
- Deploys to ECS (Fargate or EC2, per-service configuration)

**When to run**: Code deployments

---

### Testing & Validation

#### stress-test.yml

**Purpose**: Full environment lifecycle testing  
**Use Case**: Validate complete infrastructure + deployment

**Modes**:

- `standard`: Destroy → Provision → Deploy → Verify → KEEP (~30-35 min)
- `full-circle`: Standard + auto-cleanup (~35-40 min)
- `quick-test`: Test existing infrastructure (~8-10 min)
- `destroy-only`: Cleanup only (~6-8 min)

**Inputs**:

- `environment` (required): dev/stage/prod
- `target_type` (optional): host|feature-branch
- `branch_tag` (optional): Feature branch tag
- `mode` (required): Execution mode
- `include_third_party` (boolean): Test MongoDB/Elastic?
- `preserve_host` (boolean): Skip network destroy/provision?

**What it does**:

- Complete lifecycle: provision → deploy → verify
- URL health checks
- Service validation
- Optional cleanup

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

#### check-stack-exists.yml

**Purpose**: Verify Terraform state existence  
**Use Case**: Pre-flight checks

**Inputs**:

- `bucket` (required): S3 bucket name
- `state_key` (required): State file key
- `aws_region` (required): AWS region

**Outputs**:

- `exists`: true/false

**When to run**: Before destroy operations

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

## Reusable Workflows (7)

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

**Purpose**: Cleanup before infrastructure destroy  
**Inputs**: cluster_name, aws_region, force_delete  
**Outputs**: cleanup_status

---

### reusable-terraform-operations.yml

**Purpose**: Simplified Terraform operations wrapper  
**Inputs**: action, tf_dir, bucket, state_key  
**Outputs**: outputs

---

## Quick Reference

| Workflow                | Common Use             | Typical Runtime |
| :---------------------- | :--------------------- | :-------------- |
| `00_setup_environment`  | First-time setup       | 5-10 min        |
| `01-provision-infra`    | Infrastructure changes | 10-20 min       |
| `02-deploy-app`         | Code deployments       | 5-10 min        |
| `stress-test`           | Release validation     | 30-40 min       |
| `99-ops-utility`        | Ad-hoc operations      | 2-5 min         |
| `90-daily-health-check` | Daily monitoring       | 2-5 min         |

---

## Version History

**v1.0.0** (2026-01-07):

- Initial release
- 24 workflows
- 7 reusable workflows
- Hub & Spoke architecture

---

**Last Updated**: 2026-02-08  
**Maintainer**: thisisblaze/blaze-actions  
**License**: Apache 2.0
