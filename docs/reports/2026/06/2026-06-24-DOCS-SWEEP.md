# Documentation Sweep Report
**Date**: 2026-06-24
**Repository**: `blaze-actions`
**Cloud Providers Covered**: AWS, GCP, Azure
**Tag**: Automated Sweep

## 1. Root Documentation (`docs/`)
- `README.md` checked for compute patterns and `reports/YYYY/MM/` link.
- `DOCUMENTATION_INDEX.md` checked for compute patterns.
- ✅ **Passed** (Auto-Fixed): Missing phrases ("with VPC connector" and "with Managed Environment") have been corrected.

## 2. Core Agents (`.github/agents/`)
- ✅ **Passed**: `maintainer.agent.md` and `sre.agent.md` correctly reference the 12-Domain Framework, 5-Killchain Security, and all 3 cloud providers.

## 3. Agent Workflows (`.agents/workflows/`)
- ⚠️ **Cross-Provider Gaps**: `docs/ai-workflows/` does not exist for the required 1:1 mapping. (Pending manual resolution).
- ✅ **Passed** (Auto-Fixed): `.agents/workflows/09-deploy-image-resize.md` now references the `cloud_provider` input correctly.
- ✅ **Passed**: No hardcoded tenant secrets found.

## 4. Infrastructure Stacks (`.github/{aws,gcp,azure}/`)
- ✅ **Passed**: AWS and GCP modules are correctly pinned to latest version (`v2.10.1`).
- ✅ **Passed** (Auto-Fixed): GCP Cloudflare providers are now correctly constrained to `version = "~> 5.0"`.
- ⚠️ **Cross-Provider Gaps**: The Azure (`.github/azure/`) infrastructure directory is missing entirely.

## 5. Reports & Archive
- ✅ **Passed**: No loose `.md` files in `docs/reports/` root.

## 6. Cost & Security Scan
- ✅ **Passed**: No hardcoded `AWS_ACCESS_KEY_ID` in workflows. No prohibited configurations detected across AWS or GCP.
