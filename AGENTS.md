# Byte9 Platform — Agent Context (Shared CI/CD Engine)

> This file provides project-wide context for any AI coding tool (GitHub Copilot, Cursor, Antigravity, Aider, etc.)
> For named custom agent personas, see `.github/agents/`.

## What This Is

`blaze-actions` is the **shared CI/CD engine** of the Byte9 platform. It contains all GitHub Actions workflows consumed by every tenant implementation repository.

- All workflows are reusable and called via `workflow_call` from tenant repos
- No tenant-specific secrets, profile names, or account IDs should ever be stored here
- Consumers include: `blaze-template-deploy`, `shopware-km`, and any future client repos

## Hard Boundaries — Never Cross

- Do **not** hardcode tenant AWS profile names, account IDs, or client-specific values in any file
- Do **not** add tenant-specific logic — keep all workflows generic and parameterised
- Do **not** modify `PROD` infrastructure without explicit human approval
- When executing `aws` CLI commands, read the **active tenant repo's** `CLAUDE.md` to find the correct `AWS_PROFILE`

## AI Agent Personas

See `.github/agents/` for named custom agents:
- `@maintainer` — Ecosystem Guardian, documentation sweeps, workflow releases
- `@sre` — Health checks, incident response, AWS troubleshooting

> [!TIP]
> **Antigravity 2.0 Standard**: The legacy `docs/prompts` directory has been **deleted and deprecated**. All AI instructions, system prompts, and personas MUST reside in `.agent/workflows/` and `.github/agents/`. Agents must be invoked autonomously using these definitions.
