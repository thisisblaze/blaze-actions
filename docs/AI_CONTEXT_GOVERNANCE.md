**Last Updated**: 2026-06-23
**Owner**: Infrastructure Team

---

# AI Context Governance: Google Antigravity 2.0 Standard

> [!TIP]
> **Status: SCALED (ECS Fargate Environment & Environment Agnostic)**. All agents (including Google Antigravity 2.0) must enforce and operate within the ECS Fargate architectural boundaries (Legacy EB is deprecated).
> 
> **Antigravity 2.0 Standard**: This ecosystem is environment-agnostic. Workflows, context, and MCP tools rely strictly on the `.agents/` directory paradigm. Do not assume execution originates from a specific IDE or local GUI. The agent operates identically across headless CLI, background pipelines, and interactive IDE sessions.

**STATUS: MANDATORY**
**TARGET AUDIENCE: AI AGENTS, DEVELOPERS, ARCHITECTS**
**REPO ROLE**: Application Implementation & Infrastructure Instantiation (Hub)

## 1. The Prime Directive

**NEVER ASSUME HARDCODED NAMES.**
In the Blaze ecosystem, "blaze" is just a default. Real-world deployments use dynamic namespaces (e.g., `mybrand`, `client-x`).

- ❌ **Bad Assumption**: Resource is named `blaze-api-cluster` (assumes 'blaze' namespace).
- ✅ **Correct Logic**: Resource is named `${NAMESPACE}-api-cluster`. Always use placeholders like `{namespace}`, `{client}`, `{project}`, `{stage}` in analysis.

### 1.2. The Prime Directive of Non-Destruction

**ZERO AUTONOMOUS DESTRUCTION POLICY.**
The AI Agent is strictly forbidden from executing ANY autonomous command that deletes, removes, or destroys cloud infrastructure (e.g. AWS CLI deletions) or local repository files (e.g. rm commands).

- ❌ **Bad Action**: Running a script or CLI statement with `SafeToAutoRun=true` that silently deletes AWS resources.
- ✅ **Correct Action**: Output the proposed destruction/deletion command inside a markdown code block, halt execution entirely, and ask the human operator: *"Are you okay with me running this deletion command?"* Only proceed if explicitly approved.

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

## 11. Deployment Architecture Facts (2026-05-12)

**Status: MANDATORY — agents must not assume older patterns**

| Fact                               | Detail                                                                                             |
| :--------------------------------- | :------------------------------------------------------------------------------------------------- |
| **Core Architecture Paradigm**     | **ECS Fargate (ARM64 Graviton2)** — Blue/Green deployment via ALB listener swap. Elastic Beanstalk is **deprecated fallback only**. |
| **Application Deployment**         | **AWS ECS Fargate** — Docker image built on `ubuntu-24.04-arm`, pushed to ECR, deployed via task definition update + ALB swap |
| **Database Strategy**              | **Dedicated Services** — Standalone RDS MySQL (`db.t4g.small`) and ElastiCache Redis per environment |
| **Network Security**               | **Zero-Trust Model** — RDS and Redis allow ingress ONLY from the ECS Task Security Group           |
| **Background Workers**             | **ECS Sidecar containers** — `shopware-worker` and `shopware-scheduler` as essential=false sidecars in the same task definition |
| **VPC CIDRs**                      | Managed via `vars/{environment}.env` (e.g., `vpc_cidr=10.98.0.0/16` for Dev, `10.3.0.0/16` for Prod) |
| **Module Version**                 | `blaze-terraform-infra-core` @ **v2.6.4**                                                          |

## 12. CI/CD Gotchas & Known Failure Patterns (2026-04-01)

> [!CAUTION]
> These are **confirmed production failure patterns**. Agents must check for these before modifying any workflow.

| Pattern | Symptom | Root Cause | Fix |
| :------ | :------- | :--------- | :-- |
| **GitHub env case-sensitivity** | `NPM_TOKEN` empty in Docker build jobs; `@blaze-cms` package install fails | Job-level `environment:` key passed uppercase (`STAGE`) — GitHub creates blank env with no secrets instead of resolving named `stage` env | Always use lowercase: `dev`, `stage`, `prod`, `dev-mini`, `shopware` in all `environment:` keys and `workflow_dispatch` options |
| **Dependency graph race** | App stack provisions before DB pod is ready | `reusable-stress-test-provision.yml` did not declare explicit `needs:` on data pod jobs | Ensure `provision-app` job declares `needs: [provision-db-pod-alpha]` |

## 13. Current Version Pins (2026-05-15)

| Component | Current Pin | Notes |
| :-------- | :---------- | :---- |
| `blaze-actions` | **v2.1.85** | Latest stable — nuke hardening: IGW CLI-delete (v2.1.84 P1), Atlas GROUP_NOT_FOUND guard (v2.1.84 P1), CF DNS catch-all state rm (v2.1.85 P2), VPC force-delete fallback (v2.1.85 P3). All 25 workflows at @v2.1.85. |
| `blaze-terraform-infra-core` | **v2.6.4** | Plan 158: Blaze:StackID tag propagated to all resources via label module. All live stacks bumped 2026-05-14. |
| Terraform AWS Provider | **v6.0+** | Required for ECS Fargate ARM64 task definitions. |

## 14. Shopware Project Configuration (2026-05-12)

> [!IMPORTANT]
> The Shopware KM platform uses **ECS Fargate (ARM64 Graviton2)** per stage. Elastic Beanstalk is a **deprecated fallback** — present in `03-debug-eb.yml` for emergency use only. All primary deployments are ECS.

### Environment Variable Files

Configuration overrides and infrastructure settings are explicitly defined in:
- `vars/dev.env`
- `vars/stage.env`
- `vars/prod.env`

These files determine `vpc_cidr`, `ecs_task_cpu`, `ecs_task_memory`, `rds_instance_class`, and `cpu_architecture`.

### ECS Fargate Deployment Rule

Each environment runs isolated ECS clusters (`{namespace}-{env}-cluster`). Blue/Green is managed via ALB target group swap in `02-deploy-app.yml`. Container entrypoint handles `theme:compile`, Redis flush, and `cache:clear` on every startup.

---

## 15. Terraform State Isolation Rule (2026-04-30)

> [!CAUTION]
> **MANDATORY FOR ALL AGENTS AND DEVELOPERS.** Violation = immediate pipeline risk.

**Every environment MUST have its own isolated Terraform state key. No two environments (dev, stage, prod) may share the same `.tfstate` file.**

### Required State Key Pattern

For Shopware KM, the pattern is strictly:
```
shopware-km/{environment}/terraform.tfstate
```

| Token | Rule |
|-------|------|
| `{environment}` | MUST use `var.stage` — `dev`, `stage`, `prod` |

### Backend Bucket Configuration

The AWS S3 backend bucket must follow this exact format:
```
thisisblaze-{environment}-shopware-terraform-state
```

And the DynamoDB lock table:
```
thisisblaze-{environment}-shopware-terraform-locks
```

### Enforcement

- Any new `backend "s3" {}` block without `${stage}` correctly interpolated in both the bucket name and state key **must be rejected in code review**.

---

_This document governs the interaction between Human Intent and AI Execution. Deviation results in broken pipelines._

## 17. Token Budget Policy (Token Frugality & Grep-First)

**Status: MANDATORY**

Token Context is a finite, depletable resource. To prevent context window bloat and maintain high-fidelity LLM reasoning, all Agents must obey the following:

- **Minimal Viable Information (MVI)**: Never load cloud context speculatively. Only load what is strictly necessary.
- **The Grep-First Rule**: For any reference document > 100 lines (e.g. `NETWORK_STACK_RESOURCES.md`), you MUST use `grep_search` before falling back to reading the entire file with `view_file`.
- **Handoff Trigger Zone**: When approaching the remaining 5% Context Window Safety Buffer, you MUST proactively trigger `/slash-handoff` to securely freeze state rather than hitting the hard limit.
- **Anti-Patterns**: Reading all three cloud topology graphs simultaneously, running recursive directory listings on the repo root, and loading the full Governance policy when only checking a single flag are strictly forbidden.
