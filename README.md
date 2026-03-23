# Blaze GitHub Actions

**Reusable GitHub Actions workflows and composite actions for CI/CD**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Version](https://img.shields.io/badge/version-v1.5.0-blue.svg)](https://github.com/thisisblaze/blaze-actions/releases)

> [!CAUTION]
> ### 🚨 THIS REPO IS A WORKFLOW LIBRARY — NOT FOR DIRECT RUNS 🚨
>
> `blaze-actions` is a **reusable workflow and composite action library only**.
> It is the **parent/source** consumed by deployment repos like `blaze-template-deploy`.
>
> **❌ NEVER DO from this repo:**
> - Run workflows directly from this repo's GitHub Actions tab
> - Add cloud secrets (`GH_PAT`, `AWS_ROLE_ARN`, `GCP_*`, etc.) to this repo
> - Trigger stress tests, provisioning, or deploys from this repo
> - Assume any secrets set here will be available during workflow runs
>
> **✅ ALWAYS use instead:**
> - **`blaze-template-deploy`** for ALL actual workflow runs and deployments
> - Local path: `/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy`
> - GitHub: `github.com/thebyte9/blaze-template-deploy`
>
> Edit workflow _logic_ here → test and run it from `blaze-template-deploy`.


---

## Overview

Centralized GitHub Actions workflows and composite actions for infrastructure provisioning, application deployment, and operations.

**Architecture**: Hub & Spoke  
**Pattern**: DRY (Don't Repeat Yourself)  
**Versioning**: Semantic Versioning

---

## Quick Start

### For New Projects

📚 **See [CLIENT_ONBOARDING.md](https://github.com/thebyte9/blaze-template-deploy/blob/main/CLIENT_ONBOARDING.md)** for complete setup guide

### Using Workflows (Any Organization)

**From any organization** (public repository):

```yaml
# Recommended: Pin to specific version for stability
jobs:
  provision:
    uses: thisisblaze/blaze-actions/.github/workflows/01-provision-infra.yml@v1.2.0-multi-cloud-foundation
    with:
      environment: dev
      project: myproject
      stack: app
      # Multi-Cloud & Hybrid Inputs
      cloud_provider: aws # aws, gcp, or azure
      api_launch_type: FARGATE # or EC2
      apply: true
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
      GH_PAT: ${{ secrets.GH_PAT }}
      # ... other required secrets
```

**For development/testing**:

```yaml
uses: thisisblaze/blaze-actions/.github/workflows/01-provision-infra.yml@dev
```

### Using Actions (Any Organization)

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: thisisblaze/blaze-actions/.github/actions/setup-blaze@v1.4.31
        with:
          project_key: myproject
```

---

## Version Pinning Recommendations

> [!IMPORTANT] > **Production environments** should always pin to specific versions (e.g., `@v1.4.31`) for stability and predictability. **Development environments** can use `@dev` for latest features.

| Use Case                 | Recommended Version              | Example            |
| :----------------------- | :------------------------------- | :----------------- |
| **Production**           | Specific version                 | `@v1.4.31`          |
| **Staging**              | Specific version or latest minor | `@v1.4.31` or `@v1` |
| **Development**          | Latest dev branch                | `@dev`             |
| **Testing new features** | Specific commit SHA              | `@abc123f`         |

**Benefits of version pinning**:

- ✅ Predictable deployments (no surprise breaking changes)
- ✅ Easy rollback (revert to previous version)
- ✅ Clear change management (review CHANGELOG before upgrading)
- ✅ Testing isolation (test new versions in dev before production)

See [CHANGELOG.md](./CHANGELOG.md) for version history and upgrade notes.

---

## 🏷️ Namespace Configuration

All cloud resources created by these workflows are prefixed with a configurable **namespace** to support multi-tenancy and organizational isolation.

### Default Namespace

By default, all resources use the `"blaze"` namespace:

```bash
# Example resource names with default namespace:
blaze-b9-thisisblaze-dev-cluster        # ECS Cluster
blaze-b9-thisisblaze-dev-vpc            # VPC
blaze-b9-thisisblaze-dev-storage-origin # S3 Bucket
b9-dev-blaze-tfstate                    # Terraform State Bucket
```

### Resource Naming Pattern

```
${namespace}-${client_key}-${project_key}-${stage_key}-${resource}
```

### Custom Namespace

To use a custom namespace, set it in your environment configuration:

**File:** `vars/blaze-env.json` or `vars/${PROJECT_KEY}/blaze-env.json`

```json
{
  "common": {
    "NAMESPACE": "mycompany"
  }
}
```

This will result in resource names like:

```bash
mycompany-b9-thisisblaze-dev-cluster
mycompany-b9-thisisblaze-dev-vpc
b9-dev-mycompany-tfstate
```

> [!WARNING]
> **Changing the namespace for an existing environment requires a full rebuild.**
>
> All resources will be recreated with new names. You must:
>
> 1. Export data from the existing environment
> 2. Run the nuke workflow to destroy all resources
> 3. Update the NAMESPACE in your configuration
> 4. Re-provision infrastructure
> 5. Restore data

### Namespace in Workflows

The namespace is automatically loaded by `reusable-calculate-config.yml` and available in all workflows:

```yaml
jobs:
  configuration:
    uses: thisisblaze/blaze-actions/.github/workflows/reusable-calculate-config.yml@v1
    with:
      environment: dev
      terraform_stack: app

  my-job:
    needs: configuration
    runs-on: ubuntu-latest
    steps:
      - name: Use namespace
        run: |
          echo "Namespace: ${{ needs.configuration.outputs.namespace }}"
          echo "Cluster: ${{ needs.configuration.outputs.cluster_name }}"
```

**Configuration Outputs:**

| Output         | Description               | Example                            |
| -------------- | ------------------------- | ---------------------------------- |
| `namespace`    | Resource namespace prefix | `blaze` (default)                  |
| `client_key`   | Client identifier         | `b9`                               |
| `project_key`  | Project identifier        | `thisisblaze`                      |
| `stage_key`    | Environment stage         | `dev`, `stage`, `prod`             |
| `cluster_name` | Full ECS cluster name     | `blaze-b9-thisisblaze-dev-cluster` |

### Why Use Custom Namespaces?

- **Multi-tenancy**: Run multiple isolated environments for different clients
- **Organization isolation**: Separate resources by business unit or team
- **Testing**: Create isolated test environments with different naming
- **Cost tracking**: Easier resource tagging and cost allocation by namespace

---

## Welcome to Blaze Actions! 👋

This repository provides **production-ready GitHub Actions workflows** for deploying cloud infrastructure and applications. Whether you're a new user or an existing team member, we're here to help you get started quickly.

### 🚀 Getting Started

**New to Blaze Actions?** Follow these steps:

1. **Read the Client Onboarding Guide**: Start with [CLIENT_ONBOARDING.md](https://github.com/thebyte9/blaze-template-deploy/blob/main/CLIENT_ONBOARDING.md) for a complete 1-hour setup walkthrough

2. **Clone the Template**: Get started with a pre-configured repository structure

   ```bash
   git clone https://github.com/thebyte9/blaze-template-deploy my-project
   ```

3. **Review Examples**: Check out [workflow examples](https://github.com/thebyte9/blaze-template-deploy/tree/main/docs/examples) for different deployment patterns

4. **Configure Secrets**: Set up required GitHub secrets (see [secret requirements](https://github.com/thebyte9/blaze-template-deploy/blob/main/CLIENT_ONBOARDING.md#secret-requirements))

5. **Deploy**: Run your first workflow from the GitHub Actions tab

### 🎯 What You Can Do

- ✅ Deploy multi-environment infrastructure (DEV-MINI / DEV / STAGE / PROD)
- ✅ Multi-cloud support (AWS, GCP, Azure) via `cloud_provider` routing
- ✅ **Native ECS Blue/Green** API deployments (no CodeDeploy)
- ✅ ECS Fargate + EC2 Hybrid (Graviton ARM64, bin-packing)
- ✅ **Admin SPA deploy**: S3 sync + CloudFront invalidation for AWS DEV/STAGE/PROD
- ✅ GCP Cloud Run and Azure Container Apps provisioning
- ✅ Cloudflare Pages (Admin on DEV-MINI) and Tunnels management
- ✅ MongoDB Atlas and Elastic Cloud provisioning
- ✅ Feature branch deployments for testing
- ✅ Comprehensive health checks and monitoring

### 📚 Key Resources

| Resource                                                                                                                            | Description                       |
| :---------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------- |
| [CLIENT_ONBOARDING.md](https://github.com/thebyte9/blaze-template-deploy/blob/main/CLIENT_ONBOARDING.md)                            | Complete setup guide (~1 hour)    |
| [Workflow Examples](https://github.com/thebyte9/blaze-template-deploy/tree/main/docs/examples)                                      | Ready-to-use templates            |
| [CHANGELOG.md](./CHANGELOG.md)                                                                                                      | Version history and release notes |
| [Architecture Guide](https://github.com/thebyte9/blaze-template-deploy/blob/main/docs/plans/hybrid_workflow_implementation_plan.md) | How it all works                  |

### 💬 Need Help?

- **Questions**: Open a [GitHub Discussion](https://github.com/thisisblaze/blaze-actions/discussions)
- **Issues**: Report bugs via [GitHub Issues](https://github.com/thisisblaze/blaze-actions/issues)
- **Documentation**: Browse the full [workflow catalog](#workflow-catalog-24-workflows) below

### 🌟 Why Choose Blaze Actions?

- **Production-Ready**: Used by multiple organizations in production
- **Secure by Default**: OIDC authentication, SHA-pinned actions, zero long-lived credentials
- **Cost-Optimized**: Timeout protection, Fargate Spot, efficient caching
- **Well-Documented**: Comprehensive guides, examples, and inline comments
- **Actively Maintained**: Regular updates, security patches, and improvements

---

## Workflow Catalog (24 workflows)

### Main Workflows

**00_setup_environment.yml** - Initial project setup

- Sets up OIDC, state backend, secrets

**01-provision-infra.yml** - Infrastructure provisioning

- Terraform plan/apply for network and app stacks (Creation only - use 99 for destroy)

**02-deploy-app.yml** - Application deployment

- Docker build, push, ECS deploy

**stress-test.yml** - Full environment testing

- Complete lifecycle: provision → deploy → verify → cleanup

### Operations Workflows

**99-ops-utility.yml** - Multi-purpose operations

- View config, check stacks, manual interventions

**90-daily-health-check.yml** - Automated monitoring

- Daily health checks, alerts

**sync-secrets-from-ssm.yml** - Secret synchronization

- Sync AWS SSM → GitHub Secrets

**smart-dashboard.yml** - Status dashboard

- Real-time infrastructure status

### Testing Workflows

**05_ci_no_cloud.yml** - Local validation

- Terraform fmt, validate, security scans

**10_security_scan.yml** - Security scanning

- Trivy, Terrascan, tfsec

**terraform-tests.yml** - Terraform module tests

- Automated module testing

### Utility Workflows

**debug-lock.yml** - State lock debugging
**force-unlock.yml** - Force unlock state
**fix-state-integrity.yml** - State integrity repair
**fix-cname-conflict.yml** - CNAME conflict resolution
**nuke-cloudfront.yml** - CloudFront cleanup
**check-stack-exists.yml** - Stack existence check

### Reusable Workflows (7)

**reusable-calculate-config.yml** - Config loading
**reusable-terraform.yml** - Terraform operations
**reusable-docker-build.yml** - Docker build/push
**reusable-ecs-deploy.yml** - ECS deployment
**reusable-ecs-service-management.yml** - ECS service ops
**reusable-pre-destroy-cleanup.yml** - Pre-destroy cleanup
**reusable-terraform-operations.yml** - Terraform ops wrapper

---

## Composite Actions (5 actions)

### calculate-config

Loads configuration from `vars/*.json` files

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/calculate-config@v1
  with:
    environment: dev
```

### deploy-ecs-service

Deploys application to ECS

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/deploy-ecs-service@v1
  with:
    cluster_name: my-cluster
    service_name: api
    image_tag: v1.0.0
```

### docker-promote

Promotes Docker images between environments

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/docker-promote@v1
  with:
    source_tag: dev-123
    target_tag: stage-123
```

### resource-importer

Imports existing AWS resources to Terraform

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/resource-importer@v1
  with:
    resource_type: aws_s3_bucket
    resource_id: my-bucket
```

### setup-blaze

Initial project setup and configuration

```yaml
- uses: thisisblaze/blaze-actions/.github/actions/setup-blaze@v1
  with:
    project_key: myproject
```

---

## Usage Examples

### Example 1: Call Reusable Workflow

```yaml
# In your repo (.github/workflows/deploy.yml)
name: Deploy to Production

on:
  workflow_dispatch:

jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1
    with:
      environment: prod
      project_key: myproject
    secrets: inherit
```

### Example 2: Use Composite Action

```yaml
# In your repo (.github/workflows/build.yml)
name: Build Application

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: thisisblaze/blaze-actions/.github/actions/calculate-config@v1
        with:
          environment: dev

      - name: Build
        run: npm run build
```

### Example 3: Chain Multiple Workflows

```yaml
jobs:
  provision:
    uses: thisisblaze/blaze-actions/.github/workflows/01-provision-infra.yml@v1
    with:
      environment: dev
    secrets: inherit

  deploy:
    needs: provision
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1
    with:
      environment: dev
    secrets: inherit
```

---

## Features

✅ **Centralized**: One place for all workflows/actions  
✅ **Reusable**: Call from any project in same org  
✅ **Versioned**: Pin to specific versions  
✅ **OIDC**: No long-lived cloud credentials (AWS, GCP WIF, Azure)  
✅ **SHA-Pinned**: All actions pinned to commit SHAs  
✅ **Timeout Protected**: All workflows have limits
✅ **Observability**: Detailed provisioning summaries (ALB, IAM, Cluster)

---

## Documentation

- [Workflow Catalog](docs/WORKFLOW_CATALOG.md) - All 24 workflows documented
- [Reusable Workflows Guide](docs/REUSABLE_WORKFLOWS.md) - How to use
- [Contributing Guide](CONTRIBUTING.md) - How to add workflows

## Versioning

**Current Version**: `v1.5.0`

Follow semantic versioning:

- **Major**: Breaking changes to workflow inputs/outputs
- **Minor**: New workflows/actions (backwards-compatible)
- **Patch**: Bug fixes, documentation

---

## Support

**Issues**: [GitHub Issues](https://github.com/thisisblaze/blaze-actions/issues)  
**Organization**: thisisblaze  
**License**: Apache 2.0

---

## Quick Reference

| Workflow               | Purpose                  | Inputs                                             |
| :--------------------- | :----------------------- | :------------------------------------------------- |
| **01-provision-infra** | Provision infrastructure | env, stack, cloud_provider, api_launch_type |
| **02-deploy-app**      | Deploy App + Admin SPA   | env, cloud_provider, api_launch_type, target_services |
| **reusable-stress-test-*** | Full environment test suite    | environment, mode                           |
| **99-ops-utility**     | Operations utility       | action, confirmation (cleanup integrated)   |

> Environments: `dev-mini` | `dev` | `stage` | `prod`
> Admin SPA: S3+CloudFront on DEV/STAGE/PROD · Cloudflare Pages on DEV-MINI

See [WORKFLOW_CATALOG.md](docs/WORKFLOW_CATALOG.md) for complete reference.
