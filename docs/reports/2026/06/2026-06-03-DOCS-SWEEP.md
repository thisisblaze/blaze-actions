# Documentation Maintenance Sweep

**Date**: 2026-06-03  
**Repository**: `blaze-actions`  
**Cloud Providers Covered**: AWS, GCP, Azure  
**Type**: Automated Sweep

---

## Folder-by-Folder Audit

### 1. Root Documentation (`docs/`)
- **Status**: ❌ Failed
- **Finding**: `DOCUMENTATION_INDEX.md` is missing entirely. It must exist, mention all compute patterns (AWS Hybrid ECS, GCP Cloud Run, Azure Container Apps), and link to `reports/YYYY/MM/` and `AI_CONTEXT_GOVERNANCE.md`.

### 2. Core Agents (`.github/agents/`)
- **Status**: ❌ Failed
- **Finding**: `maintainer.agent.md` and `sre.agent.md` lack the required references to the **12-Domain Framework**, **5-Killchain Security**, and **all 3 cloud providers**. 

### 3. Agent Workflows (`.agents/workflows/`)
- **Status**: ❌ Failed
- **Finding**: The rule states workflows must map 1:1 with `docs/ai-workflows/`, but the `docs/ai-workflows/` directory does not exist. (Note: `AGENTS.md` states the legacy directories were deprecated in favour of `.agents/workflows`, so this rule in the `/09-maintain-docs` workflow might be legacy itself, but technically fails the check).

### 4. Infrastructure Stacks (`.github/{aws,gcp,azure}/`)
- **Status**: ✅ Passed (AWS & GCP)
- **Finding**: Module references and versions are consistent. Azure is not currently provisioned in this library.

### 5. Reports & Archive (`docs/reports/`)
- **Status**: ⚠️ Auto-Fixed
- **Finding**: Found loose file `2026-06-02-best-practice-audit.md` in root of `docs/reports/`. It needs to be moved to `docs/reports/2026/06/`. `docs/reports/README.md` index needs to be created.

---

## Cost & Security Pattern Scan (Multi-Cloud)

### AWS
- `ec2_max_size` → ❌ Failed. Found `ec2_max_size` default set to `2` in `.github/aws/infra/live/dev-mini-network/variables.tf`. Must be `1` for Stage/Dev.
- `AWS_ACCESS_KEY_ID` → ✅ Clean. No hardcoded keys found in workflows.
- `origin_access_identity` → ✅ Clean.

### GCP
- `min_instances = 0` → ✅ Clean. Set correctly for dev/stage.
- `force_destroy_storage` → ✅ Clean. False for Prod, True for Dev.
- `create_dns_records` → ✅ Clean. Explicitly set.

### Azure
- `min_replicas` → ✅ Clean (N/A)
- `ARM_CLIENT_SECRET` → ✅ Clean. None found.

---

## Report Finalization

**Passed Folders**:
- Infrastructure Stacks (AWS, GCP)

**Failed Files (Pending Fixes)**:
1. `docs/DOCUMENTATION_INDEX.md` (Missing)
2. `.github/agents/maintainer.agent.md` (Missing required references)
3. `.github/agents/sre.agent.md` (Missing required references)
4. `.github/aws/infra/live/dev-mini-network/variables.tf` (Cost control violation)
5. `docs/reports/README.md` (Missing index)

**Auto-Fixed Items**:
- Moved `docs/reports/2026-06-02-best-practice-audit.md` to `docs/reports/2026/06/`.
