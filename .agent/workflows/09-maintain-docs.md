---
description: Perform a comprehensive folder-by-folder audit of the repository's documentation.
---

# Workflow: Documentation Maintenance Sweep

This workflow performs a **Comprehensive Folder-by-Folder Audit** of the repository's documentation, ensuring alignment with **February 2026 Standards** (Stage Safety, Hybrid ECS, 12-Domain Framework).

> **Trigger**: Run this monthly or when requested to "sweep docs".

## Phase 1: Preparation

1.  **Initialize Report**:
    - Create a new report file: `docs/reports/YYYY/MM/YYYY-MM-DD-DOCS-SWEEP.md`.
    - Add header with Date, Repository Name, and "Automated Sweep" tag.

## Phase 2: Folder-by-Folder Audit

Iterate through these directories. For each, check **Date Freshness** (< 30 days) and **Architecture Alignment**.

### 1. Root Documentation (`docs/`)

- **Check**: `README.md`.
- **Criteria**:
  - Must link to `reports/YYYY/MM/` (not loose files).
  - Must mention "Hybrid ECS" (not just Fargate).

### 2. Agent Workflows (`.agent/workflows/`)

- **Check**: All `.md` files.
- **Criteria**:
  - Must NOT contain hardcoded `b9` or `thisisblaze` (unless in examples).

## Phase 3: Cost & Security Pattern Scan

Run `grep` checks to find banned or required patterns.

1.  **Cost Control (Stage Safety)**:
    - Search for `timeout-minutes`.
    - **Rule**: MUST be present in all reusable workflows to prevent billing runaways.

2.  **Security Governance**:
    - Search for `AWS_ACCESS_KEY_ID`.
    - **Rule**: BANNED in workflows.
    - Search for `origin_access_identity` (OAI).
    - **Rule**: Legacy. Should recommend OAC.

## Phase 4: Report Finalization

1.  **Compile Output**:
    - List **Passed** Folders.
    - List **Failed** Files (with reason).

2.  **Notify User**:
    - Present summary.
