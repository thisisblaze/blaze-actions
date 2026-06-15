# Blaze AI Constraints & Agent Rules

> **Status: SCALED (Multi-Tenant V2)**. All agent operations must adhere to the Phase 1 Foundation / Phase 2 Tenant orchestrated mapping logic.

## 1. The 4-Repo Architecture
The Blaze ecosystem consists of 4 distinct functional layers (repositories):
1. **Tenant Implementation Repo** (e.g., `blaze-template-deploy`, `shopware-km`): The central hub and orchestration layer. Contains tenant-specific configurations, state mappings, and client endpoints.
2. `blaze-actions`: The shared CI/CD engine. All workflows and orchestration pipelines execute from here.
3. `blaze-terraform-infra-core`: The shared infrastructure module registry. Contains pure, agnostic Terraform modules.
4. `blaze-conductor`: The AI Orchestration layer containing MCP servers.

**CRITICAL RULE**: Do not duplicate workflows or modules into the Tenant Implementation Repo. Always reference them natively from the shared parent repositories (`blaze-actions` / `blaze-terraform-infra-core`).

## 2. Agent Workflows & The 5-Role Model
When executing slash commands or workflows in `.agent/workflows/`, you must adopt the specified role to maintain context:
- 🧑‍💼 **Product Manager (PM)**: Analysis, requirements gathering, planning (`/01-analyze`, `/engage`).
- 🎨 **Designer**: UI/UX architecture and aesthetic validation.
- 🔧 **Engineer**: Writing code, fixing bugs, deploying infrastructure (`/04-troubleshoot`, `/05-fix`).
- 🕵️ **QA**: Code review, testing, consistency checks (`/08-qa`, `/08-audit`, `/02-test`).
- 🚨 **SRE**: Monitoring, health checks, incident response (`/03-monitor`, `/12-stress-test-report`, `/checkengines`).

## 3. Technology Stack & Parity
- **Infrastructure**: Terraform (S3 Backend, DynamoDB Locking). Native AWS ECS Fargate/EC2 Blue/Green. **NO CodeDeploy**.
- **CI/CD**: GitHub Actions.
- **Environment Model**:
  - `DEV-MINI`: Local/Feature-branch sandbox (Cloudflare Tunnel).
  - `DEV`: Mirrored staging layer.
  - `STAGE`: Pre-production.
  - `PROD`: Production layer.

## 4. Execution Directives
- **Grep-First**: Always use `grep_search` to verify file existence and contents before modifying or reading blindly.
- **Graceful Degradation**: Workflows support both native Antigravity 2.0 tools and Claude Code CLI fallbacks. Follow the conditional logic blocks `💡 Antigravity 2.0` vs `💡 Claude Code` exactly.
- **Slash Commands**: If the user asks for a command like `/01-analyze`, manually read the file in `.agent/workflows/` and execute it step by step.

## 5. File Exclusions (Claude Code / Cowork)
Do NOT read, index, or modify these paths (mirrors `.agentignore`):
- `docs/archive/` — archived historical docs, not current
- `**/.terraform/` — Terraform provider binaries and downloaded modules
- `**/.terraform.lock.hcl` — lock files, not human-edited

## 6. AWS Profile Mapping
**SECURITY RULE**: This is an open, shared parent repository used by many different tenants. Do NOT hardcode AWS Profile names here.
When executing AWS commands, you must either:
1. Inspect the *active tenant repository's* `CLAUDE.md` file (e.g., `thebyte9/blaze-template-deploy/CLAUDE.md` or `thebyte9/shopware-km/CLAUDE.md`) to find the tenant's specific AWS profile mapping and use it.
2. Or, if unavailable, STOP and prompt the user to provide the exact `AWS_PROFILE` before proceeding.
