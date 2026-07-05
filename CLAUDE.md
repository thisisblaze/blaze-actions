# Blaze AI Constraints & Agent Rules

> **Status: SCALED (Multi-Tenant V2)**. All agent operations must adhere to the Phase 1 Foundation / Phase 2 Tenant orchestrated mapping logic.

@.claude/rules/architecture.md

@.claude/rules/roles.md

@.claude/rules/stack.md

@.claude/rules/execution.md

@.claude/rules/exclusions.md

## 6. AWS Profile Mapping
**SECURITY RULE**: This is an open, shared parent repository used by many different tenants. Do NOT hardcode AWS Profile names here.
When executing AWS commands, you must either:
1. Inspect the *active tenant repository's* `CLAUDE.md` file (e.g., `thebyte9/blaze-template-deploy/CLAUDE.md` or `thebyte9/shopware-km/CLAUDE.md`) to find the tenant's specific AWS profile mapping and use it.
2. Or, if unavailable, STOP and prompt the user to provide the exact `AWS_PROFILE` before proceeding.

## 7. Branch Policy & Releases
- **Branch Flow**: All new work starts on `dev` and promotes `dev → stage → main`.
- **Superset Rule**: `dev` must always be a superset of `main` (ahead, never behind).
- **Releases**: Release tags are cut exclusively from `main`.
- **Hotfixes**: Any hotfix applied directly to `main` must be back-merged to `dev` immediately.
