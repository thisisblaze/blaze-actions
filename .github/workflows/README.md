# GitHub Actions Workflows

This directory contains the modernized CI/CD pipeline for the Blaze project, organized into a quadruple-lifecycle system.

## 🏗️ Core Lifecycle Workflows

The system is centered around four primary workflows that manage the entire lifecycle of an environment:

| Workflow                          | ID   | Purpose                         | Key Features                                                                                                                             |
| :-------------------------------- | :--- | :------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------- |
| **00 - Setup Environment**        | `00` | **Initial Bootstrap**           | One-time creation of S3 Backend, DynamoDB Locks, and ECR Image Mirroring.                                                                |
| **01 - Provision Infrastructure** | `01` | **Infrastructure Provisioning** | Creates VPC, ECS Clusters, ALB, EFS, SSL Certificates, and 3rd Party (Mongo/Elastic).                                                    |
| **02 - Deploy App**               | `02` | **Application Delivery**        | Builds Docker images and deploys to ECS or Cloudflare Pages. Supports selective service deploys.                                         |
| **99 - Ops Utility**              | `99` | **Operational Maintenance**     | Manage environment state (Scale/Stop), unlock Terraform, wipe state, destroy resources, and Cloudflare cleanup (Pages/Deployments/Bulk). |

---

## 🛠️ Specialty & CI Workflows

These workflows handle automated checks and background tasks:

- **`05 CI (No Cloud)`**: Fast validation (Lint, Unit Tests) that runs on every PR and push. No cloud credentials required.
- **`10_security_scan.yml`**: Holistic security auditing (Gitleaks, Semgrep, Trivy).
- **`sync-secrets-from-ssm.yml`**: Sync AWS SSM parameters (MongoDB/Elastic credentials) to GitHub Secrets for CI/CD use.
- **`Daily System Monitor`**: Automated daily validation of live system health (API, ECS, SSL).
- **`Terraform Module Tests`**: Validation of shared Terraform modules.
- **`force-unlock.yml`**: Unlock Terraform state locks (DynamoDB + S3 cleanup).
- **`debug-lock.yml`**: Inspect Terraform state locks for troubleshooting.
- **`fix-state-integrity.yml`**: Verify and repair Terraform state file integrity.
- **`fix-cname-conflict.yml`**: Remove CNAMEs from CloudFront distributions.

---

## ☁️ Cloudflare Operations

Specialized workflows for managing Cloudflare Pages lifecycle:

- **`destroy-cloudflare-pages`** (in `99-ops-utility.yml`): Delete a single Cloudflare Pages project
  - Dynamic project naming from configuration (no hardcoded values)
  - Enhanced error handling with retry logic for rate limits
  - Requires `DESTROY` confirmation
- **`cleanup-cloudflare-deployments`** (in `99-ops-utility.yml`): Clean up old deployments while keeping recent ones
  - Dual retention: by count (keep last N) OR age (keep newer than N days)
  - Dry-run mode enabled by default
  - Reduces storage costs and clutter
- **`destroy-cloudflare-pages-bulk`** (in `99-ops-utility.yml`): Pattern-based bulk deletion
  - Pattern matching (e.g., `blaze-*-test*-admin`)
  - Safety limit: max 10 projects per run
  - Requires `BULK_DESTROY` confirmation
  - Dry-run support for preview

- **`destroy-cloudflare-tunnel`** (in `99-ops-utility.yml`): Delete Cloudflare Tunnels by pattern
- **`sync-cloudflare-config`** (in `99-ops-utility.yml`): Sync environment variables to Cloudflare Pages

---

## ⚙️ Reusable Engine

Workflows under the hood that power the core lifecycle:

- `reusable-terraform.yml`: The Terraform engine (init/plan/apply).
- `reusable-docker-build.yml`: Optimized Docker build and push.
- `reusable-ecs-deploy.yml`: Standardized ECS deployment logic.
- `calculate-config.yml`: The brain that derives all project and environment keys.

---

## 📁 Legacy Archive

Legacy workflows (00, 20, 50, 60, 70, etc.) have been moved to the [archive/](archive/) directory. They are preserved for historical reference but are no longer active in the new system.

---

## 📘 Documentation

For detailed guides, see:

- [Operations Manual](../../docs/operations_manual.md): Running the system day-to-day.
- [Build & Deploy Guide](../../docs/BUILD_AND_DEPLOY_GUIDE.md): Technical details on Docker and Deployments.
- [Testing Guide](../../docs/TESTING_GUIDE.md): How to run local tests and CI.
