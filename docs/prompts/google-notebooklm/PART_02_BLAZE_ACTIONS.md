# PART 2: blaze-actions - CI/CD Automation Hub

**Document Purpose:** Deep dive into blaze-actions repository for Google NotebookLM  
**Target Length:** 3-4 minutes of presentation content  
**Focus:** Workflows, automation, and the hub & spoke pattern

---

## blaze-actions: The Automation Hub

### Repository Overview

**Purpose:** Centralized GitHub Actions workflows and automation for the entire Blaze ecosystem

**Key Statistics:**

- **24 reusable workflows** - Complete CI/CD lifecycle
- **5 composite actions** - Reusable task components
- **15 lines per project** - Instead of 400+ duplicated lines
- **10+ consuming projects** - Proven at scale

**Location:** `github.com/thisisblaze/blaze-actions`

---

## The 4 Core Lifecycle Workflows

### 1. Workflow `00` - Setup Environment 🛠️

**Purpose:** Bootstrap new environment from scratch

**What it does:**

1. Creates S3 backend for Terraform state
2. Creates DynamoDB table for state locking
3. Sets up ECR repositories for Docker images
4. Configures OIDC trust relationship

**When to use:**

- First time setup for new project
- Creating new environment (DEV/STAGE/PROD)
- After infrastructure teardown

**Time:** 3-5 minutes  
**Runs:** Once per environment

**Example Usage:**

```yaml
jobs:
  setup:
    uses: thisisblaze/blaze-actions/.github/workflows/00_setup_environment.yml@v1.33.2
    with:
      environment: dev
      task: "🟢 Bootstrap All"
```

---

### 2. Workflow `01` - Provision Infrastructure 🏗️

**Purpose:** Create/update AWS infrastructure via Terraform

**What it does:**

1. Loads configuration from `vars/blaze-env.json`
2. Runs Terraform plan (preview changes)
3. Optionally applies changes (creates/updates resources)
4. Outputs infrastructure details (cluster names, ALB DNS, etc.)

**Stacks Available:**

- `network` - VPC, subnets, security groups, ALB
- `app` - ECS cluster, services, task definitions, CloudFront
- `data` - ElastiCache Redis, RDS (optional)
- `acm` - SSL certificates
- `tunnel` - Cloudflare Tunnel
- `third-party-mongodb` - MongoDB Atlas
- `third-party-elastic` - Elastic Cloud
- `gcp-network` - GCP VPC, Cloud SQL, Memorystore
- `gcp-app` - GCP Cloud Run services
- `azure-network` - Azure VNET, SQL Database
- `azure-app` - Azure Container Apps

**Time:** 5-15 minutes (depending on stack)  
**Runs:** On-demand or automated

**Example Usage:**

```yaml
jobs:
  provision:
    uses: thisisblaze/blaze-actions/.github/workflows/01-provision-infra.yml@v1.33.2
    with:
      environment: DEV
      stack: app
      apply: true # false for plan-only
```

---

### 3. Workflow `02` - Deploy Application 🚀

**Purpose:** Build and deploy application code to ECS/Cloudflare Pages

**What it does:**

1. Builds Docker images for services
2. Pushes images to ECR
3. Updates ECS task definitions
4. Deploys to ECS with circuit breakers
5. Deploys admin SPA to Cloudflare Pages
6. Runs smoke tests

**Services Supported:**

- `api` - Backend API (Node.js/Express)
- `frontend` - Web frontend (React/Next.js)
- `admin` - Admin dashboard (React SPA on Cloudflare Pages)

**Deployment Strategy:**

- Blue/green deployment for zero downtime
- Circuit breakers to prevent bad deployments
- Automatic rollback on failure

**Time:** 8-12 minutes  
**Runs:** After code changes

**Example Usage:**

```yaml
jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1.33.2
    with:
      environment: dev
      target_services: "Blaze all" # or specific: "api frontend"
      api_launch_type: "FARGATE" # or "EC2"
      capacity_provider_strategy: "default" # or custom JSON
```

---

### 4. Workflow `99` - Ops Utility 🔧

**Purpose:** Operational tasks and environment management

**Actions Available:**

- `view-config` - Display current configuration
- `check-stack-exists` - Verify Terraform stack existence
- `unlock-state` - Release stuck Terraform locks
- `nuke-environment` - Destroy entire environment
- `destroy-cloudflare-pages` - Delete Cloudflare Pages project
- `cleanup-cloudflare-deployments` - Remove old deployments
- `destroy-cloudflare-pages-bulk` - Pattern-based deletion

**Pre-Destroy Cleanup:**
Automatically runs before environment destruction:

- Drains S3 buckets
- Deletes Lambda@Edge functions
- Removes CloudFront OACs
- Cleans up orphaned IAM roles

**Time:** 2-20 minutes (depending on action)  
**Runs:** As needed

**Example Usage:**

```yaml
jobs:
  cleanup:
    uses: thisisblaze/blaze-actions/.github/workflows/99-ops-utility.yml@v1.33.2
    with:
      environment: DEV
      action: cleanup-cloudflare-deployments
      retention_count: 5
      dry_run: true
```

---

## Key Supporting Workflows

### Security & Validation

**`05_ci_no_cloud.yml` - Fast Validation**

- Terraform format check
- Terraform validate
- Runs on every PR
- No cloud credentials needed
- 2-3 minutes

**`10_security_scan.yml` - Security Audit**

- Trivy container scanning
- Semgrep code analysis
- Terraform security checks
- Generates compliance reports
- 5-8 minutes

### Monitoring & Health

**`90-daily-health-check.yml` - Automated Monitoring**

- Checks ECS service health
- Validates SSL certificates
- Monitors API endpoints
- Detects configuration drift
- Runs daily at 6 AM UTC

### Operations

**`sync-secrets-from-ssm.yml` - Secret Sync**

- Pulls MongoDB/Elastic credentials from AWS SSM
- Updates GitHub Secrets automatically
- Runs after third-party provisioning

**`stress-test.yml` - Full Lifecycle Test**

- Provision → Deploy → Verify → Cleanup
- Tests complete platform
- 30-45 minutes

---

## Reusable Workflow Engine

### The 7 Core Reusable Workflows

These power the main workflows:

1. **`reusable-calculate-config.yml`**
   - Loads configuration from JSON files
   - Calculates resource names
   - Outputs: namespace, cluster_name, all keys

2. **`reusable-terraform.yml`**
   - Terraform init, plan, apply
   - Handles state management
   - Supports pre-apply scripts

3. **`reusable-docker-build.yml`**
   - Multi-service Docker builds
   - Layer caching for speed
   - Pushes to ECR

4. **`reusable-ecs-deploy.yml`**
   - ECS service deployments
   - Blue/green strategy
   - Health check validation

5. **`reusable-ecs-service-management.yml`**
   - Start/stop/scale services
   - Service status checks

6. **`reusable-pre-destroy-cleanup.yml`**
   - **CRITICAL**: Runs before Terraform destroy
   - Prevents TF lockups by forcibly detaching EC2 Capacity Providers
   - Cleans up Lambda@Edge, S3, CloudFront, and Launch Templates

7. **`reusable-terraform-operations.yml`**
   - Wrapper for common Terraform ops
   - Unlock, show, refresh

---

## Composite Actions (Building Blocks)

### 1. calculate-config

Loads and parses environment configuration

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/calculate-config@v1
  with:
    environment: dev
```

**Outputs:** All configuration variables for the environment

### 2. setup-blaze

Initial project setup and tool installation

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/setup-blaze@v1
  with:
    project_key: myproject
```

**Installs:** Terraform, AWS CLI, jq, GitHub CLI

### 3. deploy-ecs-service

Atomic ECS deployment

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/deploy-ecs-service@v1
  with:
    cluster_name: my-cluster
    service_name: api
    image_tag: v1.0.0
```

**Handles:** Task definition update, service deployment, health checks

### 4. docker-promote

Promote images between environments

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/docker-promote@v1
  with:
    source_tag: dev-123
    target_tag: stage-123
```

**Use case:** Promote tested dev image to staging

### 5. resource-importer

Import existing AWS resources into Terraform

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/resource-importer@v1
  with:
    resource_type: aws_s3_bucket
    resource_id: my-bucket
```

**Use case:** Adopt legacy resources into IaC

---

## Hub & Spoke Implementation

### How Projects Consume blaze-actions

**Step 1: Create Thin Wrapper**

In project repository `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  workflow_dispatch:

permissions:
  id-token: write # OIDC
  contents: read

jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1.33.2
    with:
      environment: prod
      target_services: "Blaze all"
    secrets: inherit
```

**That's it!** 15 lines vs 400+

### Version Pinning Strategy

| Environment     | Version Strategy | Example            | Reason                       |
| --------------- | ---------------- | ------------------ | ---------------------------- |
| **Production**  | Specific version | `@v1.4.31`          | Stability, predictability    |
| **Staging**     | Minor version    | `@v1` or `@v1.4.31` | Balance stability & features |
| **Development** | Latest dev       | `@dev`             | Test new features            |
| **Testing**     | Specific commit  | `@abc123f`         | Exact reproducibility        |

### Update Propagation

**Scenario:** Security fix needed in workflows

**Old Way (Pre-Hub):**

1. Fix workflow in Project A
2. Copy-paste to Project B
3. Copy-paste to Project C
4. ... repeat for 10 projects
5. Time: 3-6 hours
6. Risk: Missing projects, inconsistent fixes

**New Way (Hub):**

1. Fix workflow in blaze-actions
2. Tag new version (v1.4.1)
3. Projects using `@v1` get it automatically
4. Projects using `@v1.4.31` update when ready
5. Time: 15 minutes
6. Risk: Zero (everyone gets same fix)

---

## Configuration Management

### The `vars/` Directory

**Structure:**

```
vars/
├── blaze-env.json              # Global defaults
└── thisisblaze/
    └── blaze-env.json          # Project-specific overrides
```

**Global Configuration (`vars/blaze-env.json`):**

```json
{
  "common": {
    "NAMESPACE": "blaze",
    "AWS_REGION": "eu-west-1"
  },
  "client_key": "b9",
  "project_key": "thisisblaze",
  "domain_root": "thisisblaze.com"
}
```

**How It Works:**

1. `calculate-config` action loads JSON files
2. Merges global + project-specific configs
3. Outputs as GitHub Actions variables
4. Available to all workflow steps

**Benefits:**

- Single source of truth
- Version-controlled configuration
- Easy to audit changes
- Supports multi-environment

---

## Security Features

### 1. OIDC Authentication

- No long-lived AWS keys
- Temporary credentials (1-hour lifetime)
- Automatic rotation
- Per-workflow permissions

### 2. Security Scanning

- **Trivy:** Container vulnerability scanning
- **Semgrep:** Static code analysis
- **tfsec/Terrascan:** Terraform security checks
- Runs on every commit

### 3. Secret Management

- GitHub Secrets for sensitive data
- Never logged or exposed
- Encrypted at rest
- Access controlled per environment

### 4. Principle of Least Privilege

- Each workflow gets minimum required permissions
- IAM roles scoped to specific actions
- Network security groups restrict access

---

## Workflow Orchestration Examples

### Example 1: Complete New Environment

**Goal:** Stand up DEV environment from scratch

```yaml
# Step 1: Bootstrap
run: 00_setup_environment.yml
  - Creates S3, DynamoDB, ECR
  - Time: 3 min

# Step 2: Network
run: 01_provision_infrastructure.yml (network stack)
  - Creates VPC, subnets, ALB
  - Time: 8 min

# Step 3: SSL Certificates
run: 01_provision_infrastructure.yml (acm stack)
  - Requests ACM certificates
  - Wait for DNS validation (manual, 30 min)

# Step 4: Application Infrastructure
run: 01_provision_infrastructure.yml (app stack)
  - Creates ECS, CloudFront, etc.
  - Time: 12 min

# Step 5: Deploy Code
run: 02_deploy_app.yml
  - Builds and deploys application
  - Time: 10 min

Total Time: ~1 hour (excluding DNS validation wait)
```

### Example 2: Hotfix Deployment

**Goal:** Deploy critical fix to production

```yaml
# Developer pushes fix to main branch

# Automated:
runs: 02_deploy_app.yml
  with:
    environment: prod
    target_services: "api"  # Only API service

# Workflow:
1. Builds new Docker image
2. Pushes to ECR
3. Updates ECS task definition
4. Blue/green deployment
5. Health checks pass
6. Traffic switched to new tasks

Time: 8 minutes
Downtime: 0 seconds
```

### Example 3: Environment Teardown

**Goal:** Clean up test environment

```yaml
run: 99_ops_utility.yml
  with:
    action: nuke-environment
    confirmation: NUKE

# Automated cleanup:
1. Pre-destroy cleanup workflow:
   - Drains S3 buckets
   - Deletes Lambda@Edge
   - Removes CloudFront resources
   - Cleans IAM roles

2. Terraform destroy (app stack)
3. Terraform destroy (network stack)
4. Remove Cloudflare Pages
5. Clean up Terraform state

Time: 15-20 minutes
Cost: $0 going forward
```

---

## Key Innovations

### 1. Dynamic Namespace Support

- Resources named with configurable prefix
- Enables multi-tenancy
- No hardcoded values
- Document: namespace_architecture.mermaid

### 2. Pre-Destroy Cleanup

- Automatically handles dependencies
- Prevents "resource in use" errors
- Cleans up zombie resources
- Makes teardown reliable

### 3. Hybrid Deployment (Compute & Cloud)
- **Compute**: Mix Fargate (Spot) & EC2 (Performance) in same cluster
- **Cloud**: AWS (Core), GCP (Data), Azure (Compliance)
- **Static**: Cloudflare Pages for global edge delivery

### 4. Environment Protection

- Manual approval gates
- Circuit breakers
- Automated rollback
- Health check validation

---

## Best Practices Enforced

1. **Version Pinning**
   - Production uses tagged versions
   - Development tests latest
   - Clear update path

2. **Secrets Management**
   - OIDC over access keys
   - GitHub Secrets for runtime
   - No secrets in code

3. **Infrastructure as Code**
   - Everything in Terraform
   - Plan before apply
   - Audit trail in Git

4. **Automated Testing**
   - Terraform validate on PR
   - Security scans on commit
   - Daily health checks

5. **Documentation**
   - Every workflow documented
   - Examples provided
   - Troubleshooting guides

---

**Document Version:** 1.0  
**Last Updated:** 2026-03-16  
**For:** Google NotebookLM Presentation Generation  
**Estimated Presentation Time:** 3-4 minutes
