# Blaze AI Constraints & Agent Rules

> **Status: SCALED (Multi-Tenant V2)**. All agent operations must adhere to the Phase 1 Foundation / Phase 2 Tenant orchestrated mapping logic.

## 1. The 4-Repo Architecture
The Blaze ecosystem consists of 4 distinct repositories:
1. `blaze-template-deploy`: The central hub and orchestration layer. Contains tenant configurations, state mappings, and client endpoints.
2. `blaze-actions`: The shared CI/CD engine. All workflows and orchestration pipelines execute from here.
3. `blaze-terraform-infra-core`: The shared infrastructure module registry. Contains pure, agnostic Terraform modules.
4. `blaze-conductor`: The AI Orchestration layer containing MCP servers.

**CRITICAL RULE**: Do not duplicate workflows or modules into `blaze-template-deploy`. Reference them from the shared repositories.

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
