# NotebookLM Infographic Prompt — `blaze-actions`

> **Instructions for NotebookLM**: Using the source documents provided, generate a text-based infographic layout suitable for a designer to turn into a visual graphic. Structure the output as clearly labelled sections. Focus on clarity, brevity, and visual storytelling.

---

## INFOGRAPHIC BRIEF: blaze-actions — The Shared CI/CD Engine

### ONE SENTENCE HEADLINE
> **"One public repo powers the entire platform — 54 reusable workflows, 3 cloud providers, and an AI agent command system that any tenant can adopt in 16 lines of YAML."**

---

### KEY STATS

- **54** GitHub Actions workflows (30 main + 24 reusable)
- **21** AI agent slash commands
- **3** cloud providers: AWS, GCP, Azure
- **11** "Smart Fixes" knowledge articles
- **4** stress test phases (composable pipeline)
- **1** public repo shared by all tenant clients
- **~16 lines** of YAML is all a tenant needs to call ANY workflow
- **0** long-lived credentials — pure OIDC everywhere

---

### THE HUB & SPOKE MODEL

```
┌────────────────────────────────────────────┐
│          blaze-actions (PUBLIC)            │
│  The CI/CD engine — all logic lives here   │
│                                            │
│  54 workflows │ 24 reusable │ 3 clouds     │
└──────────────────┬─────────────────────────┘
     calls via     │  uses: @v2.2.2
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
  blaze-deploy  shopware-km  future-client
  (thebyte9)   (KELSEYMedia)   (any tenant)
  ~16-line     ~16-line
  wrappers     wrappers
```

---

### HOW A TENANT USES THIS (3 steps)

**Step 1 — Create a thin wrapper (16 lines)**
```yaml
jobs:
  deploy:
    uses: thisisblaze/blaze-actions/
      .github/workflows/02-deploy-app.yml@v2.2.2
    with:
      environment: prod
      cloud_provider: aws
    secrets: inherit
```

**Step 2 — Trigger from your repo**
```bash
gh workflow run "02-deploy-app.yml" \
  --repo thebyte9/blaze-template-deploy \
  -f environment=prod
```

**Step 3 — Let the engine do everything**
Docker build → ECR push → ECS Blue/Green → CloudFront invalidation → health check. All automated.

---

### WORKFLOW CATEGORIES (icon boxes)

| Category | Count | Examples |
|----------|-------|---------|
| 🏗️ Provision | 1 master | Network, ECS, ALB, DB, CloudFront |
| 🚀 Deploy | 5 | AWS ECS, GCP Cloud Run, Azure Container Apps, Pages |
| 🧪 Stress Test | 4 phases | Provision → Deploy → Verify → Teardown |
| 🩺 Health | 2 | Daily health check, ECS incident snapshot |
| 🔧 Operations | 7 | Nuke, state repair, lock release, DNS fix |
| 🔒 Security | 2 | Full audit, OIDC-only auth everywhere |
| 🤖 AI Agent | 21 | /engage, /allstop, /checkengines, /slash-handoff |

---

### SECURITY MODEL (callout)

> 🔒 **Zero long-lived credentials.** AWS uses OIDC. GCP uses Workload Identity Federation. Azure uses Managed Identity. No access keys. No secrets stored in this public repo.
>
> 🔒 **SHA-pinned actions.** Every `uses:` action uses an immutable commit SHA, not a mutable tag — preventing supply chain attacks.

---

### "DID YOU KNOW?" FACT

> 💡 The knowledge library (`docs/knowledge/`) contains 11 "Smart Fixes" articles — battle-tested solutions to non-obvious problems like "why does Terraform hang after ECS capacity provider changes?" or "why is CloudFront returning 403 to my Lambda?" These took hours to debug and are now a permanent reference.

---

### FOOTER

> Sources: `AGENTS.md`, `docs/WORKFLOW_CATALOG.md`, `docs/AI_CONTEXT_GOVERNANCE.md`, `docs/knowledge/`
