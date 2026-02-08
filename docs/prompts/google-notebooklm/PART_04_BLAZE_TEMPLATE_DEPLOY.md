# PART 4: blaze-template-deploy - Deployment Templates

**Document Purpose:** Project template and deployment patterns for Google NotebookLM  
**Target Length:** 2-3 minutes of presentation content  
**Focus:** How projects consume the platform

---

## blaze-template-deploy: The Project Template

### Repository Purpose

**What:** Template repository for new projects to clone and customize

**Contains:**

- Thin workflow wrappers (15 lines each)
- Environment configuration files
- Terraform stack definitions
- Application code structure
- Complete documentation

**Location:** `github.com/thebyte9/blaze-template-deploy`

---

## Repository Structure

```
blaze-template-deploy/
├── .github/
│   └── workflows/
│       ├── 01-provision-infra.yml      # 15 lines (wrapper)
│       ├── 02-deploy-app.yml           # 15 lines (wrapper)
│       └── 99-ops-utility.yml          # 15 lines (wrapper)
├── vars/
│   ├── blaze-env.json                  # Global config
│   └── thisisblaze/
│       └── blaze-env.json              # Project-specific
├── .github/aws/infra/live/
│   ├── dev-network/main.tf             # DEV network stack
│   ├── dev-app/main.tf                 # DEV app stack
│   ├── stage-network/main.tf           # STAGE network
│   └── stage-app/main.tf               # STAGE app
├── packages/                            # Application code
├── docs/                                # Documentation
└── CLIENT_ONBOARDING.md                 # Setup guide
```

---

## Configuration System

### Global Configuration

**File:** `vars/blaze-env.json`

```json
{
  "common": {
    "NAMESPACE": "blaze",
    "AWS_REGION": "eu-west-1"
  },
  "client_key": "b9",
  "project_key": "thisisblaze",
  "domain_root": "thisisblaze.com",
  "platform": "aws"
}
```

### Environment-Specific Overrides

**File:** `vars/thisisblaze/blaze-env.json`

```json
{
  "dev": {
    "ecs_cpu": 256,
    "ecs_memory": 512,
    "enable_autoscaling": false
  },
  "prod": {
    "ecs_cpu": 1024,
    "ecs_memory": 2048,
    "enable_autoscaling": true,
    "min_tasks": 2,
    "max_tasks": 10
  }
}
```

---

## Workflow Wrappers (The Magic)

### Before Blaze (400+ lines)

```yaml
name: Deploy
on: workflow_dispatch
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS
        # ... 50 lines ...
      - name: Setup Terraform
        # ... 30 lines ...
      - name: Load Config
        # ... 40 lines ...
  build:
    needs: setup
    # ... 100 lines ...
  terraform:
    needs: build
    # ... 120 lines ...
  deploy:
    needs: terraform
    # ... 100 lines ...
# Total: 400+ lines
```

### After Blaze (15 lines)

```yaml
name: Deploy
on: workflow_dispatch

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1.4.0
    with:
      environment: dev
    secrets: inherit
```

**Reduction: 96% less code**

---

## Terraform Stack Definitions

### Pattern: Live Directory Structure

```
.github/aws/infra/live/
├── dev-network/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── dev-app/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── ...
```

### Example: dev-network/main.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "b9-dev-blaze-tfstate"
    key            = "dev/network/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

module "network" {
  source = "git::https://github.com/thisisblaze/blaze-terraform-infra-core.git//modules/environment-network?ref=v2.0.0"

  namespace   = var.namespace
  client_key  = var.client_key
  project_key = var.project_key
  stage_key   = "dev"

  vpc_cidr = "10.0.0.0/16"
  azs      = ["eu-west-1a", "eu-west-1b"]
}

output "vpc_id" {
  value = module.network.vpc_id
}
```

**Pattern Benefits:**

- Clear separation by environment
- No workspace confusion
- Easy to understand
- Simple to modify

---

## Deployment Patterns

### Pattern 1: New Project Setup

**Time:** 1 hour

**Steps:**

1. Clone blaze-template-deploy
2. Update `vars/blaze-env.json`
3. Configure GitHub secrets
4. Run 00_setup_environment (bootstrap)
5. Run 01_provision_infrastructure (network)
6. Run 01_provision_infrastructure (app)
7. Run 02-deploy-app

**Result:** Fully functional DEV environment

### Pattern 2: Multi-Environment Rollout

**Goal:** DEV → STAGE → PROD

**Approach:**

```
1. Test in DEV
2. Promote image to STAGE
3. Validate in STAGE
4. Manual approval gate
5. Promote to PROD
6. Gradual rollout (blue/green)
```

### Pattern 3: Feature Branch Testing

**Use Case:** Test feature before merging

**Flow:**

1. Create feature branch
2. Deploy to dev-feature-123
3. Test thoroughly
4. Merge to main
5. Deploy to dev
6. Cleanup feature environment

---

## Client Onboarding

### The Onboarding Document

**File:** `CLIENT_ONBOARDING.md`

**Sections:**

1. Prerequisites
2. Quick Start (1-hour setup)
3. Secret Requirements
4. **Namespace Configuration** (NEW!)
5. Configuration Guide
6. Workflow Usage Examples
7. Troubleshooting

**Goal:** Any engineer can set up in 1 hour

---

## Visual Documentation

### Mermaid Diagrams

**Created:**

- `namespace_architecture.mermaid` - Config to resources flow
- `resource_naming_pattern.mermaid` - Naming examples
- `namespace_before_after.mermaid` - Hardcoded vs dynamic
- `workflow_01_provision.mermaid` - Provision workflow
- `workflow_02_deploy.mermaid` - Deploy workflow
- `architecture_hybrid.mermaid` - Hybrid ECS + Cloudflare

**Purpose:** Help engineers understand the system visually

---

## Best Practices Encoded

### 1. Environment Protection

**Production workflows:**

```yaml
jobs:
  deploy-prod:
    uses: ...
    environment: PROD # Requires manual approval in GitHub
```

### 2. Version Pinning

**Development:**

```yaml
uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@dev
```

**Production:**

```yaml
uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1.4.0
```

### 3. Secret Management

**Never in code:**

- Passwords
- API keys
- AWS credentials

**Always in GitHub Secrets:**

```yaml
secrets:
  AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
  MONGO_CONNECTION: ${{ secrets.MONGO_CONNECTION_STRING }}
```

---

## Success Story

**Team XYZ before Blaze:**

- New project setup: 2 weeks
- Infrastructure deployment: 2-3 days
- Configuration errors: Common
- Security scanning: Manual

**Team XYZ after Blaze:**

- New project setup: 1 hour
- Infrastructure deployment: 15 minutes
- Configuration errors: Rare (enforced by templates)
- Security scanning: Automatic

**ROI:** 95% time reduction, zero security incidents

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-08  
**Estimated Presentation Time:** 2-3 minutes
