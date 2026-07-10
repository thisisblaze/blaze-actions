**Last Updated**: 2026-07-10
**Owner**: Infrastructure Team

---

# AI Context Governance: Google Antigravity 2.0 Standard

> [!TIP]
> **Status: SCALED (Multi-Tenant V2 & Environment Agnostic)**. All agents (including Google Antigravity 2.0) must enforce and operate within the Phase 1 Foundation / Phase 2 Tenant orchestrated layers. 
> 
> **Antigravity 2.0 Standard**: This ecosystem is environment-agnostic. Workflows, context, and MCP tools rely strictly on the `.agents/` directory paradigm. Do not assume execution originates from a specific IDE or local GUI. The agent operates identically across headless CLI, background pipelines, and interactive IDE sessions.

**STATUS: MANDATORY**
**TARGET AUDIENCE: AI AGENTS, DEVELOPERS, ARCHITECTS**
**REPO ROLE**: Application Implementation & Infrastructure Instantiation (Hub)

> **Canon precedence (Plan 174 §B1 decision, recorded 2026-07-02 / Plan 180 Stage 2).** The authoritative source of truth is **`CLAUDE.md` + `.claude/rules/`** (per Plan 172). The per-tool entry files (`.cursorrules`, `AGENTS.md`, `GEMINI.md`) are thin pointers to `CLAUDE.md`. This document is the **extended governance reference** — it elaborates on canon and must never contradict it. On any conflict, `CLAUDE.md` / `.claude/rules/` win; fix this file to match.

## 1. The Prime Directive

**NEVER ASSUME HARDCODED NAMES.**
In the Blaze ecosystem, "blaze" is just a default. Real-world deployments use dynamic namespaces (e.g., `mybrand`, `client-x`).

- ❌ **Bad Assumption**: Resource is named `blaze-api-cluster` (assumes 'blaze' namespace).
- ✅ **Correct Logic**: Resource is named `${NAMESPACE}-api-cluster`. Always use placeholders like `{namespace}`, `{client}`, `{project}`, `{stage}` in analysis.

### 1.2. The Prime Directive of Non-Destruction

**ZERO AUTONOMOUS DESTRUCTION POLICY.**
The AI Agent is strictly forbidden from executing ANY autonomous command that deletes, removes, or destroys cloud infrastructure (e.g. AWS CLI deletions) or local repository files (e.g. rm commands).

- ❌ **Bad Action**: Running a script or CLI statement with `SafeToAutoRun=true` that silently deletes AWS resources.
- ✅ **Correct Action**: Output the proposed destruction/deletion command inside a markdown code block, halt execution entirely, and require the human operator to **explicitly type the keyword `DESTROY` or `EXECUTE`** to authorize it. Only proceed after that typed confirmation. This is the single canonical destruction gate — it matches `.claude/rules/stack.md`, the `scripts/hooks/pretooluse-guard.mjs` PreToolUse hook, and the `99-ops-*` workflow confirmation prompts. A verbal "are you okay with this?" is **not** sufficient. *(Reconciled 2026-07-02, Plan 174 §B4.3 / Plan 180 Stage 2.)*

### 1.5. Public Repository Sanitization

**CRITICAL POLICY**: Several of our repositories (such as `blaze-actions`) are **PUBLIC**. For consistency across the ecosystem:

- NEVER write or commit actual company URLs (e.g. `*.thisisblaze.uk` or client-specific variations) in shared workflows or documentation.
- NEVER include real AWS Account IDs, ARNs, or exact server IP addresses in documentation.
- ALWAYS use sanitized placeholders (e.g., `app.example.com`, `123456789012`) when producing examples in the Knowledge Library or AI workflows.

### 1.6. The Signature Tag Rule

**CRITICAL POLICY**: Generic tags like `Stage`, `Client`, and `Project` are heavily overloaded by legacy tools and other CI/CDs. 
When verifying infrastructure teardown, checking for orphaned resources, or listing active systems via raw CLI (like `aws cloudfront list-distributions`), you **MUST** filter exclusively by our unified signature tags. We employ a revolutionary UUID tag solution for stateless purges and precise environment isolation (Plan 155):
- `Blaze:StackID={UUID}`: This is the definitive, globally unique identifier injected into all resources belonging to a specific environment instance. It guarantees precise environment nuking isolation and resilience against orphaned resources.
- `Shopware:Architecture=Shopware 6.7.x`
- `Blaze:Provisioner=blaze-actions`

"Orphan hunting" using string matching on domains (e.g., `dev.b9`) without checking the `Blaze:StackID` or these exact tags/Terraform State is strictly forbidden.

## 2. The Golden Rule of Context

Before writing a single line of code or answering a complex architectural question, you **MUST** ground yourself in the current environment's reality.
**"Hallucination" of resource names is the #1 cause of deployment failure.**

## 3. The Protocol

### A. Start of Session (Bootstrapping)

**Command**: `/init-context`
_(Source: [.agents/workflows/slash-init-context.md](.agents/workflows/slash-init-context.md))_

**Action**:

1.  Read the **Constitution**: `AGENTS.md` and `.agents/workflows/`
3.  View the **Dependencies**: `docs/graphs/module_dependency_map.mermaid`
4.  **Ack**: "Context Loaded. I am ready to work on the Multi-Cloud (AWS) Blaze stack."

### B. During Execution (Navigation)

If you are unsure where a resource lives or how data flows:

1.  **Don't Guess.**
2.  **Consult the Visual Hub**: Look at `docs/graphs/`.
3.  **Trace the Config**: Look at `reusable-calculate-config.yml`.

### C. End of Cycle (Maintenance)

**Command**: `/weekly-graph`
_(Source: [.agents/workflows/slash-weekly-graph.md](.agents/workflows/slash-weekly-graph.md))_

**Trigger**: Weekly or after significant architectural changes.
**Action**:

1.  Compare actual Code vs. Visual Graphs.
2.  Update Graphs to reflect reality.
3.  This ensures the _next_ agent has accurate maps.

## 4. Data Retention Policy

| Provider | Storage                   | Logs/Ephemeral            | Persistent Data                             |
| :------- | :------------------------ | :------------------------ | :------------------------------------------ |
| AWS      | S3 Lifecycle Rules        | ✅ 30-90 day retention OK | ⚠️ RESTRICTED — "Data Loss Check" required  |

## 5. Operational Workflows (Standard Procedures)

Consult these approved workflows for specific operational tasks:

- **Analysis**: `/01-analyze` → `.agents/workflows/01-analyze.md`
- **Testing**: `/02-test` → `.agents/workflows/02-test.md`
- **Security Audit**: `/08-audit` → `.agents/workflows/08-audit.md`
- **Consistency Check**: `/cross-environment-consistency` → `.agents/workflows/cross-environment-consistency.md`
- **Image Resize Deploy**: `/09-deploy-image-resize` → `.agents/workflows/09-deploy-image-resize.md` (AWS only)
- **Troubleshooting**: `/04-troubleshoot` → `.agents/workflows/04-troubleshoot.md`
- **Docs Maintenance**: `/09-maintain-docs` → `.agents/workflows/09-maintain-docs.md`

## 6. Key References

- **Naming Standard**: `docs/reference/NETWORK_STACK_RESOURCES.md`
- **Visual Hub**: `docs/graphs/`
- **Maintenance Workflow**: `.agents/workflows/slash-weekly-graph.md`

## 7. Stage Safety Protocol (Cost Control)

**Status: MANDATORY**

To prevent runaway costs in non-production environments, all Agents MUST verify the following constraints when analyzing or modifying **Stage/Dev** infrastructure:

| Rule                | AWS                                  |
| :------------------ | :----------------------------------- | :------------------------------------------ | :-------------------------- |
| NAT Strategy        | `NONE` (Public IPs) or `INSTANCE`    | Cloud NAT (shared, low cost)                | VNet Integration (built-in) |
| Deletion Protection | `enable_deletion_protection = false` | `force_destroy_storage = true` (Dev only)   | Resource locks removed      |
| VPC Connector       | N/A                                  | `e2-micro`, max 3 instances                 | N/A                         |

**Constraint Violation**: If you see scaling above these limits in Stage/Dev, you MUST flag it as a "Cost Anomaly".

## 8. Transient Artifact Cleanup (Zero Trace Policy)

**Status: MANDATORY**

When creating temporary resources for debugging, you **MUST** ensure they are removed before completing the task.

### The Protocol:

1.  **Creation**: It is acceptable to create `temp/`, `debug/`, or `*_src/` folders for analysis.
2.  **Exclusion**: These MUST be ignored by `.gitignore` if they persist for more than one step.
3.  **Destruction**: You **MUST** delete these artifacts before declaring "Task Complete".
4.  **Verification**: Run `git status` before finishing to ensure no temporary junk is being committed.
5.  **Output Location**: ALWAYS output temporary logs to `scratch/` (e.g., `gh run view ... > scratch/debug.log`).

**Anti-Pattern (Do Not Do):**

- Leaving `lambda_src/`, `logs/`, or `config_dump.json` in the root directory.
- Committing `*.log`, `*.out`, or debugging scripts that contain hardcoded values.

## 9. Cleanup Protocol (The Law of Zero Waste)

**Status: MANDATORY**

Terraform Destroy is **NOT** enough. You MUST use the `reusable-pre-destroy-cleanup.yml` workflow before destroying any environment.

**Why?**

- **EC2 Capacity Providers**: Will hang Terraform indefinitely if not forcefully detached.
- **Launch Templates**: Will be orphaned and clutter the account.
- **Logs**: Terraform does not delete CloudWatch Log Groups by default.
- **S3 Buckets**: Non-empty buckets will cause destroy failures.

**The Rule**:

> "If you provision it, you must ensure it can be destroyed. If Terraform can't destroy it, you must script the cleanup."

## 10. Cross-Repository Architecture

| Repository                          | Role                                         | Owner         |
| :---------------------------------- | :------------------------------------------- | :------------ |
| `blaze-terraform-infra-core`        | Terraform module Source of Truth             | `thisisblaze` |
| `blaze-actions`                     | Reusable GitHub Actions workflows            | `thisisblaze` |
| `shopware-km` | Application deployment & infra instantiation | `thebyte9`    |

## 11. Deployment Architecture Facts (2026-03-25)

**Status: MANDATORY — agents must not assume older patterns**

| Fact                               | Detail                                                                                             |
| :--------------------------------- | :------------------------------------------------------------------------------------------------- |
| **Core Architecture Paradigm**     | **Multi-Site V2 (The Two-Pillar Strategy)**: Day 0 Shared Foundation, Day 1 Data Pods, Day 2 Tenants|
| **ECS API Deployment**             | **Native ECS Blue/Green** — no CodeDeploy, no `appspec.yml`, no deployment group                   |
| **CloudFront Topologies**          | **3 Distributions per Tenant** (Admin, API, Frontend). Allows extreme Blue/Green isolation         |
| **Database Strategy**              | **Strict Pod Sharding** (`pod-shared-01`, `pod-shared-02`, Dedicated) utilizing native Atlas Autoscaling |
| **Background Workers**             | **Dual-Engine Hybrid** — Fargate (Heavy Cron sweeps) & Lambda (Fast SQS events) via `WORKERS_JSON` |
| **Dev Environment (Foundation)**   | `01a-provision-network` Foundation utilizes VPC `10.4.0.0/16` and decoupled Dual ALBs                        |
| **VPC CIDRs**                      | PILLAR 1: DEV=10.0.0.0/16, STAGE=10.1.0.0/16, PROD=10.2.0.0/16. PILLAR 2 (V2): DEV=10.4.0.0/16, STAGE=10.5.0.0/16, PROD=10.6.0.0/16 |
| **Module Version**                 | See the canonical pin in `CLAUDE.md` (Module Version Pin line) — do not restate version numbers here. |
| **CodeDeploy**                     | **REMOVED**. No `aws deploy create-deployment` calls. If you see one — it is a bug                 |

## 12. CI/CD Gotchas & Known Failure Patterns (2026-04-01)

> [!CAUTION]
> These are **confirmed production failure patterns**. Agents must check for these before modifying any workflow.

| Pattern | Symptom | Root Cause | Fix |
| :------ | :------- | :--------- | :-- |
| **GitHub env case-sensitivity** | `NPM_TOKEN` empty in Docker build jobs; `@blaze-cms` package install fails | Job-level `environment:` key passed uppercase (`STAGE`) — GitHub creates blank env with no secrets instead of resolving named `stage` env | Always use lowercase: `dev`, `stage`, `prod`, `dev-mini`, `multi-site` in all `environment:` keys and `workflow_dispatch` options |
| **ECS EC2 capacity provider bootstrap** | Terraform planning hangs on `data "aws_ecs_capacity_provider"` lookup | SSM parameter `blaze-b9-thisisblaze-stage-ecs-ec2-cp` missing or wrong; dead-code SSM data sources block plan | Fix SSM parameter value; remove dead-code data sources from `multi-site-tenant-app` module |
| **Dependency graph race** | App stack provisions before DB pod is ready | `reusable-stress-test-provision.yml` did not declare explicit `needs:` on data pod jobs | Ensure `provision-app` job declares `needs: [provision-pod-shared-01]` |

## 13. Current Version Pins

> **Canonical pins live in `CLAUDE.md` (the "Module Version Pin" line).** This section intentionally no longer restates `blaze-actions` / `blaze-terraform-infra-core` version numbers — restating them here is what caused the three-way drift Plan 174 §B4.2 closed (reconciled 2026-07-02, Plan 180 Stage 2). Read `CLAUDE.md` for the current `infra-core` and `blaze-actions` pins, and respect the `# ⚠️ FREEZE` markers noted there.

| Component | Current Pin | Notes |
| :-------- | :---------- | :---- |
| `blaze-actions` | see `CLAUDE.md` | Canonical pin + FREEZE exceptions maintained in `CLAUDE.md`. |
| `blaze-terraform-infra-core` | see `CLAUDE.md` | Canonical pin maintained in `CLAUDE.md`. |
| Terraform AWS Provider | **v6.0.x** | Migrated 2026-03-23 |

---


## 14. Multi-Project Registry (April 2026+)

> [!IMPORTANT]
> The Blaze platform now supports multiple projects on a single shared ECS cluster. All AI agents MUST be aware of the active project registry before modifying any resource.

| `PROJECT_KEY`  | `DOMAIN_ROOT`      | `PROJECT_SLUG` | Infra                    | Status        |
|:--------------|:------------------|:--------------|:------------------------|:--------------|
| `thisisblaze` | `thisisblaze.uk`  | *(empty)*      | Shared cluster (multi-site) | ✅ Active  |
| `support`     | `thisisblaze.uk`  | `support`      | Shared cluster (multi-site) | 🔧 Phase 3 |
| `thisisblaze2`| `thisisblaze2.uk` | *(empty)*      | Shared cluster*            | 📋 Planned |

_* `thisisblaze2` requires a separate Cloudflare zone + ACM cert when the domain is registered._

### `PROJECT_SLUG` Definition

`PROJECT_SLUG` is the suffix appended to domain names for sub-projects on a shared zone:
- `thisisblaze`: no slug (primary project, no suffix) → `frontend-dev.thisisblaze.uk`
- `support`: slug = `support` → `frontend-dev-support.thisisblaze.uk`
- DNS pattern (settled April 2026): `{service}-{env}-{slug}.{domain}` — service first, env second, slug last. Prod drops env. Primary project drops slug.

### ECS Cluster Sharing Rule

All projects share **ONE ECS cluster per environment**. Blast-radius events (cluster failure, capacity starvation) affect all projects simultaneously. Scale testing for one project must account for headroom required by others.

### Blast-Radius Safety for Nuke Operations

When destroying a multi-site environment, ALWAYS scope by `Blaze:Project` tag. **Never destroy the `multi-site-network` stack** without confirming ALL projects' services are down. See: `docs/guides/teardown_guide.md`.

### Config File Locations

| Project | blaze-env.json | Project overrides |
|:--------|:---------------|:------------------|
| thisisblaze | `vars/thisisblaze/blaze-env.json` | `projects/thisisblaze/packages/` |
| support | `vars/support/blaze-env.json` | `projects/support/packages/` |
| thisisblaze2 | `vars/thisisblaze2/blaze-env.json` | `projects/thisisblaze2/packages/` |

See: `docs/plans/archive/144_new_domain_project_onboarding.md`

## 15. Multi-Tenant Nuke Failure Patterns (2026-04-08)

> [!CAUTION]
> Discovered during Plan 134 dev environment nuke-and-reprovision cycle.

| Pattern | Symptom | Root Cause | Fix |
| :------ | :------- | :--------- | :-- |
| **pre_apply.sh TG state removal** | 503 on all endpoints after deploy | Script unconditionally removed `aws_lb_target_group` + `aws_lb_listener_rule` from TF state | Disabled destructive sections; added idempotent TG import in Section 4. See Plan 134 §6 |
| **Capacity Provider Deadlocks** | Terraform destroy hangs forever on ASG/CP | `create_before_destroy` on ASGs conflicted with tied capacity providers | Enforced `random_id` on capacity providers + injected `force_delete` on ASG |
| **IGW DependencyViolation on destroy** | `Network has some mapped public address(es)` | NAT GW EIPs still associated + EC2 instances not yet terminated when TF destroy runs | Terminate EC2s → wait `terminated` → re-run nuke. EIPs auto-release with NAT GWs |
| **CloudFront orphan after nuke** | 3 CFs remain Enabled after destroy | Nuke timed out before CF disable propagated (~15 min needed) | Manually disable → wait Deployed → delete. Add explicit CF wait to nuke hook |
| **SG DependencyViolation** | `sg has a dependent object` | EC2 ENIs still attached to SG during destroy | Terminate instances first, verify `terminated` state, then destroy SG |
| **PROJECT_SLUG must always be present** | DNS interpolation breaks for primary project | CI/CD reads `PROJECT_SLUG`; absent = undefined | Primary: `PROJECT_SLUG: ""`. Sub-projects: `PROJECT_SLUG: "support"`. Field MUST exist in `vars/{project}/blaze-env.json` |
| **Atlas GROUP_NOT_FOUND** | `DELETE: HTTP 404 Not Found (Error code: "GROUP_NOT_FOUND")` | Database cluster destroyed out-of-band via API, leaving Terraform `mongodbatlas_database_user` orphaned and failing the destroy | Run `terraform state rm` on the `mongodbatlas_database_user` resource in a `pre-destroy.sh` hook before `terraform destroy`. |

---

## 16. Terraform State Isolation Rule (2026-04-13)

> [!CAUTION]
> **MANDATORY FOR ALL AGENTS AND DEVELOPERS.** Violation = immediate pipeline risk.

**Every environment MUST have its own isolated Terraform state key. No two environments (dev, dev-mini, stage, prod, or any future ephemeral env) may share the same `.tfstate` file.**

### Required State Key Pattern

```
infra/{project_key}/{environment}/{stack_name}.tfstate
```

| Token | Rule |
|-------|------|
| `{project_key}` | MUST use `var.project_key` — never hardcoded |
| `{environment}` | MUST use `var.stage` — `dev`, `dev-mini`, `stage`, `prod` |
| `{stack_name}` | Descriptive purpose (`network`, `third-party-mongodb`, `thisisblaze-db`, `multi-site-app`) |

### Known Violations (being fixed in Plan P5.2)

| Stack | Current (Wrong) Key | Correct Key |
|-------|---------------------|-------------|
| `01d` MongoDB (stage+prod) | `infra/thisisblaze/third-party/mongodb.tfstate` | `infra/thisisblaze/stage/third-party-mongodb.tfstate` / `…/prod/…` |

### Enforcement

- Any new `backend "s3" {}` block without both `${project_key}` and `${stage}` in the key **must be rejected in code review**.
- When creating a new stack directory, always copy the pattern from a correctly-isolated stack (e.g. `multi-site-network/main.tf`).
- See: `docs/plans/april_2026_roadmap.md` § Priority 5 for the full fix plan.

---

_This document governs the interaction between Human Intent and AI Execution. Deviation results in broken pipelines._

## 17. Token Budget Policy (Token Frugality & Grep-First)

**Status: MANDATORY**

Token Context is a finite, depletable resource. To prevent context window bloat and maintain high-fidelity LLM reasoning, all Agents must obey the following:

- **Minimal Viable Information (MVI)**: Never load cloud context speculatively. Only load what is strictly necessary.
- **The Grep-First Rule**: For any reference document > 100 lines (e.g. `NETWORK_STACK_RESOURCES.md`), you MUST use `grep_search` before falling back to reading the entire file with `view_file`.
- **Handoff Trigger Zone**: When approaching the remaining 5% Context Window Safety Buffer, you MUST proactively trigger `/slash-handoff` to securely freeze state rather than hitting the hard limit.
- **Anti-Patterns**: Reading all three cloud topology graphs simultaneously, running recursive directory listings on the repo root, and loading the full Governance policy when only checking a single flag are strictly forbidden.

---

## 18. blaze-conductor MCP Governance (2026-05-27)

**Status: MANDATORY**

The Blaze platform includes a 4th repository - `blaze-conductor` - that provides AI orchestration via the Model Context Protocol (MCP). Agents working on CI/CD must respect these rules:

### The Public/Private Boundary Rule

> [!CAUTION]
> `blaze-actions` is a **public** repository. The following must **never** appear in `blaze-actions`:
> - `ANTHROPIC_API_KEY` or any LLM API key reference
> - Checkout of `blaze-conductor`
> - Any MCP server or orchestrator script

All MCP code lives in `blaze-template-deploy` (private), running **before** calling `blaze-actions` reusable workflows.

### The Three CI/CD Injection Points

| Point | Workflow | Trigger | What it does |
| :--- | :--- | :--- | :--- |
| **A - PR Review** | `11-mcp-pr-review.yml` | PR touching `.github/{cloud}/infra/**/*.tf` | ADR compliance + drift analysis posted as PR comment |
| **B - Pre-Apply** | `mcp-preflight` in `01a-provision-network.yml` | `apply=true` | Read-only state lock check before `terraform apply` |
| **C - Post-Drift** | `mcp-healing-agent` in `90-daily-health-check.yml` | Drift check failure | Healing proposal via Claude - never auto-applies |

### ADR-007 Hard Boundary

- `blaze-conductor` has **zero** ability to trigger `destroy: true`
- `destroy: false` is hardcoded statically in all `01a-01g` YAML callers
- Healing proposals are text output only - they require human execution
- PROD healing requires `ALLOW_PROD_HEALING=true` (not set by default)

### Reference

- [ADR-017](architecture/adr_017_conductor_mcp_integration.md) - full decision record
- [Plan 152](plans/152_mcp_cicd_integration.md) - implementation record
- [blaze-conductor](https://github.com/thisisblaze/blaze-conductor) - live repo
