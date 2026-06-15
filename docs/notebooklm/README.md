# NotebookLM Prompts — `blaze-actions`

These prompts are designed to be pasted into [NotebookLM](https://notebooklm.google.com) with this repository (or its key documentation files) as the source material.

They generate educational content for colleagues who want to understand how the Blaze shared CI/CD engine works — the reusable workflow architecture, the 54+ workflows, the multi-cloud deployment model, and the AI agent slash-command system.

---

## Prompt Files

| File | Format | Target Audience | Duration |
|------|--------|-----------------|---------|
| [PROMPT_INFOGRAPHIC.md](./PROMPT_INFOGRAPHIC.md) | Visual infographic brief | Anyone — quick overview | 2 min read |
| [PROMPT_PODCAST_SHORT.md](./PROMPT_PODCAST_SHORT.md) | Podcast script | Engineers new to the stack | ~8 min listen |
| [PROMPT_PODCAST_LONG.md](./PROMPT_PODCAST_LONG.md) | Deep-dive podcast | Senior engineers & architects | ~35 min listen |

---

## How to Use

1. Open [NotebookLM](https://notebooklm.google.com)
2. Create a new notebook and add sources:
   - Upload: `docs/AI_CONTEXT_GOVERNANCE.md`, `docs/WORKFLOW_CATALOG.md`, `AGENTS.md`, `README.md`
   - Or paste the full WORKFLOW_CATALOG directly
3. Open the desired prompt file, copy the full contents
4. Paste into the NotebookLM chat

---

## What This Repo Is

`blaze-actions` is the **shared CI/CD engine** of the Byte9 Blaze platform — a public GitHub repository containing 54+ reusable GitHub Actions workflows consumed by all tenant repos.

```
THIS REPO (blaze-actions) — PUBLIC — CI/CD Hub
  ↑ called by all tenant repos via:
  uses: thisisblaze/blaze-actions/.github/workflows/01-provision-infra.yml@v2.2.2

Callers (Spokes — private tenant repos):
  thebyte9/blaze-template-deploy
  thebyte9/shopware-km
  KELSEYMedia/shopware-km
  ... any future client
```

> ⚠️ **Important**: Workflows are triggered FROM tenant repos. Never triggered directly from this repo for production infrastructure.
