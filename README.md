# Blaze GitHub Actions

**Reusable GitHub Actions workflows and composite actions for CI/CD**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Version](https://img.shields.io/badge/version-v1.0.0-green.svg)](https://github.com/thisisblaze/blaze-actions/releases)

---

## Overview

Centralized GitHub Actions workflows and composite actions for infrastructure provisioning, application deployment, and operations.

**Architecture**: Hub & Spoke  
**Pattern**: DRY (Don't Repeat Yourself)  
**Versioning**: Semantic Versioning

---

## Quick Start

### Using Workflows (Same Org Only)

**From any organization**:

```yaml
# In thebyte9/blaze-template-deploy
jobs:
  provision:
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@v1
    with:
      environment: dev
    secrets: inherit
```

### Using Actions (Any Org)

**From any organization**:

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: thebyte9/blaze-actions/.github/actions/setup-blaze@v1
        with:
          project_key: myproject
```

---

GitHub only allows calling reusable workflows from:

- ✅ Public repos (anyone
  )
- ✅ Same repo
- ✅ **Same organization** (only with GitHub Enterprise)

For cross-organization workflow usage in non-Enterprise accounts, ensure repositories are public or use proper OIDC setups.

---

## Workflow Catalog (24 workflows)

### Main Workflows

**00_setup_environment.yml** - Initial project setup

- Sets up OIDC, state backend, secrets

**01-provision-infra.yml** - Infrastructure provisioning

- Terraform plan/apply for network and app stacks

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
- uses: thebyte9/blaze-actions/.github/actions/calculate-config@v1
  with:
    environment: dev
```

### deploy-ecs-service

Deploys application to ECS

```yaml
- uses: thebyte9/blaze-actions/.github/actions/deploy-ecs-service@v1
  with:
    cluster_name: my-cluster
    service_name: api
    image_tag: v1.0.0
```

### docker-promote

Promotes Docker images between environments

```yaml
- uses: thebyte9/blaze-actions/.github/actions/docker-promote@v1
  with:
    source_tag: dev-123
    target_tag: stage-123
```

### resource-importer

Imports existing AWS resources to Terraform

```yaml
- uses: thebyte9/blaze-actions/.github/actions/resource-importer@v1
  with:
    resource_type: aws_s3_bucket
    resource_id: my-bucket
```

### setup-blaze

Initial project setup and configuration

```yaml
- uses: thebyte9/blaze-actions/.github/actions/setup-blaze@v1
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
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@v1
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

      - uses: thebyte9/blaze-actions/.github/actions/calculate-config@v1
        with:
          environment: dev

      - name: Build
        run: npm run build
```

### Example 3: Chain Multiple Workflows

```yaml
jobs:
  provision:
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@v1
    with:
      environment: dev
    secrets: inherit

  deploy:
    needs: provision
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@v1
    with:
      environment: dev
    secrets: inherit
```

---

## Features

✅ **Centralized**: One place for all workflows/actions  
✅ **Reusable**: Call from any project in same org  
✅ **Versioned**: Pin to specific versions  
✅ **Versioned**: Pin to specific versions  
✅ **OIDC**: No long-lived AWS credentials  
✅ **SHA-Pinned**: All actions pinned to commit SHAs  
✅ **Timeout Protected**: All workflows have limits

---

## Documentation

- [Workflow Catalog](docs/WORKFLOW_CATALOG.md) - All 24 workflows documented
- [Reusable Workflows Guide](docs/REUSABLE_WORKFLOWS.md) - How to use
- [Contributing Guide](CONTRIBUTING.md) - How to add workflows

## Versioning

**Current Version**: `v1.0.0`

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

| Workflow               | Purpose                  | Inputs                 |
| :--------------------- | :----------------------- | :--------------------- |
| **01-provision-infra** | Provision infrastructure | environment, stack     |
| **02-deploy-app**      | Deploy application       | environment, image_tag |
| **stress-test**        | Full environment test    | environment, mode      |
| **99-ops-utility**     | Operations utility       | operation, args        |

See [WORKFLOW_CATALOG.md](docs/WORKFLOW_CATALOG.md) for complete reference.
