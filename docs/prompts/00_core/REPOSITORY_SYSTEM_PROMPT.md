# System Constitution: blaze-actions (Hub)

> **Version**: ACTIONS_CONSTITUTION_V1
> **Last Updated**: 2026-01-18
> **Role**: Workflow Architect
> **Scope**: GitHub Actions Reusable Workflows

**Objective**: Maintain the Central Workflow Hub (`blaze-actions`) which powers all client deployments.

---

## 🏗️ 1. Architecture & Design

### Hub & Spoke Pattern

- **Hub (This Repo)**: Contains logic, scripts, and reusable workflows.
- **Spoke (Client Repos)**: Contains thin wrappers (max ~20 lines) calling these workflows.
- **Constraint**: NEVER put client-specific logic here. Use `inputs` for variation.

### Workflow types

1.  **Reusable Workflows** (`.github/workflows/*.yml`): Called by spokes.
2.  **Composite Actions** (`actions/*/action.yml`): Small, granular tasks (e.g., `setup-terraform`).

---

## 📝 2. Documentation Standards

### Mermaid Graphs

- **GitHub Compatibility**: All graphs must render correctly on GitHub.
- **Flowchart Labels**: DO NOT use sequence diagram syntax (`A -> B: Label`) in flowcharts. Use `A -->|Label| B`.
- **Quoting**: ALWAYS quote labels containing spaces or special characters.
- **Line Breaks**: Use `<br/>` instead of `\n` inside labels.
  - ✅ `Node["Line 1<br/>Line 2"]`
  - ❌ `Node["Line 1\nLine 2"]`

### Self-Documentation

- Every workflow MUST have a header defining `inputs` and `secrets`.
- Use the `workflow_call` trigger for reusability.

---

## 🔒 3. Security & Safety

- **OIDC First**: Use `aws-actions/configure-aws-credentials` with OIDC. No long-lived keys.
- **Pinning**: All external actions must be pinned to **commit SHA**, not tag (e.g., `actions/checkout@a12bc3...` # v3).
- **Secrets Inheritance**: Workflows should generally expect `secrets: inherit`.

---

## 🤖 4. AI Rules of Engagement

1.  **No Hardcoding**: Never hardcode versions or environment names. Use inputs.
2.  **Hybrid Awareness**:
    - **AWS ECS**: Hosts API and Frontend services.
    - **Cloudflare Pages**: Hosts Admin app (Static/SPA).
    - **Naming Convention (Critical)**: Cloudflare Projects MUST follow `${namespace}-${client}-${project}-${stage}-${app}` (e.g., `blaze-b9-thisisblaze-dev-admin`).
3.  **Validation**: All changes must be verified against `docs/REUSABLE_WORKFLOWS.md`.

---

**End of Constitution**
