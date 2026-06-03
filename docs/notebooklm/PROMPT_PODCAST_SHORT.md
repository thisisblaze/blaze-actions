# NotebookLM Short Podcast Prompt — `blaze-actions`
## (~8 minutes, 2 hosts)

> **Instructions for NotebookLM**: Generate a conversational 2-host podcast script, ~8 minutes. Hosts: **Alex** (technical) and **Sam** (product-minded). Audience: engineers curious about this project. Tone: engaging, accessible, no jargon overload.

---

## EPISODE: "How 16 Lines of YAML Can Deploy to Three Clouds"

### 1. Hook (1 min)
- Start with a contrast: most companies have one CI/CD setup per project. This platform has ONE shared CI/CD engine used by multiple clients — and each client only needs to write ~16 lines of YAML to get the full thing.
- What is `blaze-actions`? It's a public GitHub repository containing 54 reusable GitHub Actions workflows. Every client who joins the platform just points their repo at it.

### 2. The Hub & Spoke Model (90 sec)
- Explain the model: `blaze-actions` is the Hub. Every tenant repo is a Spoke. The spoke writes a thin wrapper; the hub contains all the logic.
- The key `uses:` pattern — how a tenant calls a remote workflow with a pinned version tag.
- Why public? Transparency. Any client can inspect exactly what happens when their code is deployed.
- The Golden Rule: you trigger workflows FROM your repo, never from `blaze-actions` directly.

### 3. What Those 54 Workflows Actually Do (2 min)
- Walk through the categories: provisioning, deployment (AWS ECS, GCP Cloud Run, Azure Container Apps), stress testing (a 4-phase pipeline), operations (nuke, state repair), security scanning, health monitoring.
- The masterpiece: `reusable-pre-destroy-cleanup.yml` (71KB). Why does destroying infrastructure require a separate 71KB cleanup script? Because Terraform alone doesn't remove EC2 Capacity Providers, Launch Templates, CloudWatch Log Groups — and if you don't clean those first, `terraform destroy` hangs forever.

### 4. The Security Model (1 min)
- Zero long-lived credentials. AWS uses OIDC. GCP uses Workload Identity Federation. Azure uses Managed Identity.
- SHA-pinned actions — not mutable version tags like `@v4`, but immutable commit hashes like `@692973e3d937129bcbf40652eb9f2f61becf3332`. Prevents supply chain attacks.
- This is a public repo — no secrets, no real ARNs, no account IDs allowed anywhere in the code.

### 5. The AI Agent Slash Commands (1.5 min)
- 21 slash commands in `.agent/workflows/` — markdown procedures for AI tools like Antigravity or Cursor.
- Demo the cycle: `/engage` in the morning (pull, check governance, read sprint board), work, `/checkengines` (10-engine automated sweep), `/allstop` (commit and push all 4 repos).
- The clever one: `/orchestrate` — chains multiple sub-workflows, retries failures up to 3 times using a failure-type → recovery-workflow mapping, then escalates.

### 6. Practical Takeaway (30 sec)
- If you want to onboard a new client: create a new repo, add ~16-line wrapper workflows pointing at `blaze-actions@vX.Y.Z`, configure `blaze-env.json`, done.
- The knowledge library (`docs/knowledge/`) is worth reading even if you're not using this platform — 11 real-world debugging solutions for GitHub Actions, Terraform, ECS, and CloudFront.
