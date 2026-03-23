---
description: Perform a routine check of the documentation integrity, ensuring it adheres to Feb 2026 standards.
expected_output: Refreshed markdown files, 12-domain and killchain validations complete.
exclusions: Do NOT alter infrastructure or source code logic while auditing docs.

---

# Workflow: Documentation Maintenance Sweep

This workflow performs a **Comprehensive Folder-by-Folder Audit** of the repository's documentation, ensuring alignment with **February 2026 Standards** across **all cloud providers** (AWS, GCP, Azure).

> **Trigger**: Run monthly, daily, or when requested to "sweep docs".

## ⛔ Exclusion List

Skip these paths entirely — they are application code, not infrastructure:

```
api-content/
packages/
plugins/
projects/thisisblaze/packages/
docker-compose.yml
package-lock.json
package.json
```

## Phase 1: Preparation

1.  **Load Standards**:
    - Read `docs/AI_CONTEXT_GOVERNANCE.md` (Governance & Cost).
    - Read `docs/prompts/00_core/DAILY_DOCUMENTATION_AUDIT.md` (12-Domain Multi-Cloud Framework).
    - Read `docs/prompts/03_manual/MONTHLY_DOCUMENTATION_REVIEW.md` (Review Criteria).

2.  **Initialize Report**:
    - Create a new report file: `docs/reports/YYYY/MM/YYYY-MM-DD-DOCS-SWEEP.md`.
    - Add header with Date, Repository Name, Cloud Providers Covered, and "Automated Sweep" tag.

## Phase 2: Folder-by-Folder Audit

Iterate through these directories. For each, check **Date Freshness** (< 30 days) and **Architecture Alignment** across all 3 cloud providers.

### 1. Root Documentation (`docs/`)

- **Check**: `README.md`, `DOCUMENTATION_INDEX.md`.
- **Criteria**:
  - Must link to `reports/YYYY/MM/` (not loose files).
  - Must mention all active compute patterns:
    - AWS: "Hybrid ECS" (Fargate + EC2)
    - GCP: "Cloud Run" (with VPC connector)
    - Azure: "Container Apps" (with Managed Environment)
  - Must link to `AI_CONTEXT_GOVERNANCE.md`.

### 2. Core Prompts (`docs/prompts/00_core/`)

- **Check**: `REPOSITORY_SYSTEM_PROMPT.md`, `AGENT_PERSONA_SRE_DAEMON.md`, `DAILY_DOCUMENTATION_AUDIT.md`.
- **Criteria**:
  - Must reference **12-Domain Framework** (not 11).
  - Must reference **5-Killchain Security** (not 4).
  - Must reference **all 3 cloud providers** (not just AWS).

### 3. Agent Workflows (`.agent/workflows/`)

- **Check**: All `.md` files.
- **Criteria**:
  - Must map 1:1 with `docs/ai-workflows/`.
  - Must NOT contain hardcoded `b9` or `thisisblaze` (unless in examples).
  - `slash-init-context.md` MUST read `AI_CONTEXT_GOVERNANCE.md`.
  - Provisioning/deploy workflows MUST reference `cloud_provider` input (gcp/aws/azure).

### 4. Infrastructure Stacks (`.github/{aws,gcp,azure}/`)

- **Check**: All `main.tf`, `variables.tf`, `outputs.tf` in live stacks.
- **Criteria**:
  - Module refs must point to latest released/tested commit.
  - All stacks for the same environment must be version-consistent.
  - Provider versions must match across stacks (e.g. `cloudflare ~> 4.0` everywhere).

### 5. Reports & Archive (`docs/reports/` & `docs/archive/`)

- **Action**:
  - Identify any loose `.md` files in `docs/reports/` (root), ignoring `ENV_COMPARISON_AWS.md`.
  - **Move** them to `docs/reports/YYYY/MM/`.
  - Update `docs/reports/README.md` index.

## Phase 3: Cost & Security Pattern Scan (Multi-Cloud)

Run `grep_search` AI tool checks to find banned or required patterns. DO NOT use bash grep.

### AWS

1.  `ec2_max_size` → If mentioned for Stage/Dev, MUST be `1`.
2.  `AWS_ACCESS_KEY_ID` → BANNED in workflows (except docs warnings).
3.  `origin_access_identity` (OAI) → Document as legacy where relevant.

### GCP

1.  `min_instances = 0` → Required for Stage/Dev Cloud Run (scale to zero).
2.  `force_destroy_storage` → Must be `false` for Prod, `true` allowed for Dev.
3.  `create_dns_records` → Must be explicitly set (default is now `false`).

### Azure

1.  `min_replicas` → Must be `0` for Stage/Dev Container Apps.
2.  `ARM_CLIENT_SECRET` → BANNED (use OIDC/Managed Identity).

## Phase 4: Report Finalization

1.  **Compile Output**:
    - List **Passed** Folders (by provider).
    - List **Failed** Files (with reason and provider).
    - List **Auto-Fixed** items (e.g. moved reports).
    - List **Cross-Provider Gaps** (e.g. docs updated for AWS but not GCP).

2.  **Notify User**:
    - Present summary.
    - Ask for approval to commit fixes (if any pending).
