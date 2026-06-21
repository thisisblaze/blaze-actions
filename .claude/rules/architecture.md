## 1. The 4-Repo Architecture
The Blaze ecosystem consists of 4 distinct functional layers (repositories):
1. **Tenant Implementation Repo** (e.g., `blaze-template-deploy`, `shopware-km`): The central hub and orchestration layer. Contains tenant-specific configurations, state mappings, and client endpoints.
2. `blaze-actions`: The shared CI/CD engine. All workflows and orchestration pipelines execute from here.
3. `blaze-terraform-infra-core`: The shared infrastructure module registry. Contains pure, agnostic Terraform modules.
4. `blaze-conductor`: The AI Orchestration layer containing MCP servers.

**CRITICAL RULE**: Do not duplicate workflows or modules into the Tenant Implementation Repo. Always reference them natively from the shared parent repositories (`blaze-actions` / `blaze-terraform-infra-core`).
