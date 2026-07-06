# NotebookLM Deep-Dive Podcast Prompt — `blaze-actions`
## (~35 minutes, 2 hosts)

> **Instructions for NotebookLM**: Generate a 2-host deep-dive podcast, ~35 minutes. Hosts: **Alex** (engineering depth, "how does this actually work?") and **Sam** (architectural, "why did you design it this way?"). Audience: senior engineers and architects. Structured as named chapters. Include trade-off discussions, honest reflection on what's hard, and technical specifics.

---

## EPISODE: "Building a Shared CI/CD Engine for a Multi-Client Platform"

---

### CHAPTER 1: "Why a Shared CI/CD Engine?" (4 min)

- The problem: you have multiple client repos all needing the same deployment patterns. Copy-paste Terraform and YAML everywhere? Or build something reusable?
- The insight: GitHub's `workflow_call` trigger lets one repo's workflows BE the workflow engine for other repos. `blaze-actions` is built entirely around this.
- The Hub & Spoke model: `blaze-actions` is public (transparent to all clients), logic-rich. Tenant repos are private, logic-thin (~16 lines of YAML per workflow).
- The **Golden Rule**: you always trigger from the tenant repo, never from `blaze-actions` directly. Why? Because GitHub Actions secrets are scoped to the triggering repo — if you run from `blaze-actions`, you have no tenant secrets.

---

### CHAPTER 2: "Inside the Workflow Catalog — 54 Workflows" (8 min)

- Walk through the categories with real examples:

**Provisioning (`01-provision-infra.yml`)**: The master multi-cloud provisioning workflow. 50+ inputs. Routes by `cloud_provider` (aws/gcp/azure) and `stack` (network/app/db-pod/dedicated). Always dry-run by default (`apply: false`). Includes `calculate-config` composite action that loads `blaze-env.json` and produces standardised outputs.

**Deployment (02-deploy-*.yml)**: Four cloud-specific deploy workflows + a multi-cloud dispatcher. AWS = Docker → ECR → native ECS Blue/Green (no CodeDeploy — explicitly removed after 3 failed attempts). GCP = Docker → Artifact Registry → Cloud Run traffic shift. Azure = Docker → ACR → Container Apps new revision.

**Stress Testing (4-phase pipeline)**: The old monolithic stress test was decomposed into 4 composable reusable workflows. You can run them independently: just provision and skip teardown for debugging; skip provisioning if stacks already exist; run just the verify phase to check a live environment.

**The 71KB cleanup workflow**: `reusable-pre-destroy-cleanup.yml` must run before any `terraform destroy`. Explains WHY: ECS Capacity Providers have a detachment lock — if you `terraform destroy` while they're attached to an ECS cluster, Terraform hangs indefinitely waiting for AWS to release the lock. Same for Launch Templates, non-empty S3 buckets, CloudFront associations.

**The Knowledge Library**: 11 `docs/knowledge/` articles covering the hardest Terraform/GitHub Actions/ECS bugs. Each one represents hours of debugging. Sanitised (no real company data) but fully reproducible.

---

### CHAPTER 3: "Multi-Cloud Without Madness" (6 min)

- Three cloud providers, structurally parallel:
  - AWS: ECS Fargate ARM64 (Graviton2) + optional EC2 hybrid + CloudFront + WAF + Lambda@Edge
  - GCP: Cloud Run v2 + Cloud CDN + Cloud Armor + Memorystore
  - Azure: Container Apps + Front Door + Azure CDN

- The `cloud_provider` input is the routing mechanism. One workflow, three execution paths.

- Dev environment differences: dev-mini uses Cloudflare Tunnel instead of CloudFront (no CDN cost), no Lambda@Edge, Admin SPA on Cloudflare Pages instead of S3+CloudFront. Cost difference: $0 CDN vs $55-220/month.

- The `dev-mini` environment stacks live IN `blaze-actions` (not in the tenant repo). Why? The dev-mini network is always present regardless of which client is active — it's the engine's own test environment.

- Sam asks: "How do you decide which cloud for a new client?" Alex explains: the platform is cloud-agnostic at the workflow level. Client choice drives `cloud_provider` input. The module library has parallel implementations for each cloud. Decision tree: cost → latency → existing infrastructure → compliance.

---

### CHAPTER 4: "Security Architecture — Zero Trust in CI/CD" (5 min)

- OIDC everywhere. AWS: `configure-aws-credentials` with `role-to-assume` + OIDC provider. GCP: Workload Identity Federation. Azure: Managed Identity + OIDC. Zero long-lived credentials — no access keys, no client secrets in workflows.

- SHA-pinned actions: every `uses:` in every workflow uses an immutable commit SHA. Why? A mutable tag like `@v4` can be updated by the action maintainer to point to malicious code. A SHA cannot be changed. This is supply chain security at the dependency level.

- Public repo sanitisation rules: no real company URLs, no AWS Account IDs, no ARNs, no client names in any workflow. Use `app.example.com`, `123456789012`. This is enforced by `docs/AI_CONTEXT_GOVERNANCE.md` and checked by the `/checkengines` security patterns engine.

- The `ALLOWED_INFRA_USERS` gate: infrastructure workflows check a list of approved GitHub usernames before running. Prevents junior devs from accidentally triggering a production provision.

- Timeout protection: every job has `timeout-minutes:`. This is mandatory — without it, a hung Terraform run costs money indefinitely.

---

### CHAPTER 5: "The AI Agent Layer" (7 min)

- Introduce the `.agents/workflows/` directory: 21 markdown files, each defining a slash-command procedure for AI tools (Antigravity, Cursor, Claude).

- The session lifecycle:
  - `/engage` — morning startup: git pull all 4 repos, check 14 governance files per repo, read sprint board from `HANDOFF.md`, check module version sync (Python script), report overnight commits. Output: START-OF-DAY REPORT.
  - Work happens.
  - `/checkengines` — runs `run_sweep.py`, a Python orchestrator that checks: docs freshness, graph drift, module versions (must match across both repos), security patterns (no hardcoded names), hygiene (no stale files), workflow parity. Read-only — no auto-fixes.
  - `/allstop` — evening: full governance sync, CHANGELOG update, commit all repos.

- The `/slash-handoff` → `/slash-resume` cycle as context management engineering:
  - When an AI's context window approaches 95% capacity, `/slash-handoff` fires: reads existing `HANDOFF.md`, updates sprint board (in-progress → paused, new → todo), prepends a journal entry, commits and pushes. Freezes state.
  - In a new session: `/slash-resume` pulls latest, reads `HANDOFF.md`, claims a task (marks as IN PROGRESS, immediately commits as a distributed lock), executes.
  - Alex: "This is effectively distributed task claiming using git as a coordination layer."

- The `/orchestrate` meta-workflow: reads high-level intent, chains sub-workflows, runs 3 retry attempts on failure using a failure-type→recovery-workflow map, escalates to human after 3 failures.

- The auto-learning system (`config.yml`): agent captures learnings after >3 debug iterations, complexity ≥7 root causes, same error appearing twice. Learnings stored in `.agents/learnings/` for future sessions.

---

### CHAPTER 6: "Lessons from the Trenches" (3 min)

- What's hard about shared CI/CD: the blast radius when you update a workflow and it breaks ALL tenant repos simultaneously. This is why version pinning (`@v2.11.55`) is critical — tenants opt into upgrades.

- The known gotchas worth sharing:
  1. GitHub Actions environment case-sensitivity: always use `dev`, `stage`, `prod` in lowercase. `STAGE` silently creates an empty environment with no secrets.
  2. The Terraform state lock auto-release: `reusable-terraform.yml` detects DynamoDB locks older than 15 minutes and releases them automatically. But the lock `Created` timestamp is nested inside a JSON blob inside the DynamoDB `Info.S` field — extracting it requires careful `jq` parsing, not a direct attribute read.
  3. The ECS Capacity Provider deadlock: if you don't detach Capacity Providers before `terraform destroy`, AWS refuses to delete the ECS cluster and Terraform hangs indefinitely.

- Sam closes: "If someone wanted to build something like this for their own company, where would they start?"
- Alex: "Start with the `workflow_call` trigger pattern. Build one reusable workflow for your most common operation. Version-tag it immediately. Add SHA pinning to all actions. Then build the governance — the `AI_CONTEXT_GOVERNANCE.md` is actually the most important file in this whole system."

---

### OUTRO (30 sec)

> "Full source in `AGENTS.md`, `docs/WORKFLOW_CATALOG.md`, and `docs/knowledge/` — all linked in the show notes."
