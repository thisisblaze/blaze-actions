---
description: Bootstraps the AI with targeted architectural context mapping (Token Frugal)
expected_output: Loaded cloud context corresponding to the requested cloud provider.
exclusions: Do NOT provision resources or read exhaustive unrelated documentation.
---

# Targeted Context Initialization

Run this with an argument (e.g. `/slash-init-context aws` or `/slash-init-context azure`) to load only the specific files necessary for that domain.

---

## 🗺️ THREE-REPO ARCHITECTURE (Always Active)

Before loading cloud context, internalize these rules. They apply regardless of cloud provider.

### Repos & Their Roles

| Repo | GitHub Org/Name | Purpose |
|------|----------------|---------|
| **`blaze-template-deploy`** | `thebyte9/blaze-template-deploy` | **Workflow trigger point.** All `gh workflow run` commands go here. Contains `live/` Terraform stacks for dev/stage/prod. |
| **`blaze-actions`** | `thisisblaze/blaze-actions` | **Reusable workflow source.** All `.github/workflows/reusable-*.yml` and `resource-importer/import.sh` live here. Also owns `dev-mini` Terraform stacks. |
| **`blaze-terraform-infra-core`** | `thisisblaze/blaze-terraform-infra-core` | **Terraform module source.** All `modules/` live here. Must be tagged before use in `live/` stacks. |

### The Golden Rule for GitHub Actions

```bash
# ✅ CORRECT — workflows always triggered from blaze-template-deploy
gh workflow run "01-provision-infra.yml" --repo thebyte9/blaze-template-deploy --ref dev ...

# ❌ WRONG — never trigger production infra workflows from blaze-actions
gh workflow run "01-provision-infra.yml" --repo thisisblaze/blaze-actions ...
```

### The Golden Rule for Module Refs

```hcl
# ✅ CORRECT — pinned tag, cache-safe, deterministic
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/networking/environment-network?ref=v1.49.0"

# ❌ RISKY — branch ref, GitHub Actions caches the old archive, changes are invisible
source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/networking/environment-network?ref=dev"
```

When bumping module versions, update `?ref=` in **both** repos if the environment exists in both:
- `blaze-template-deploy/.github/aws/infra/live/<env>-network/main.tf`
- `blaze-actions/.github/aws/infra/live/<env>-network/main.tf`

### Environment → Stack Location

| Environment | Stack Repo | Stack Path |
|-------------|-----------|-----------|
| `dev` | `blaze-template-deploy` | `.github/aws/infra/live/dev-network/` |
| `dev-mini` | `blaze-actions` | `.github/aws/infra/live/dev-mini-network/` |
| `stage` | `blaze-template-deploy` | `.github/aws/infra/live/stage-network/` |
| `prod` | `blaze-template-deploy` | `.github/aws/infra/live/prod-network/` |

All environments still trigger workflows from `thebyte9/blaze-template-deploy`.

---

## Steps

### 1. Identify Target Cloud

If the user did not specify a cloud provider, ask them which one they are working on (aws, gcp, azure).

### 2. Targeted Load

Based on the exact provider only load the following:

- **AWS**: `view_file docs/graphs/aws_resource_topology.mermaid` in `blaze-template-deploy`
- **GCP**: `view_file_outline` or check `docs/graphs/` for the GCP equivalent.
- **Azure**: `view_file_outline` or check `docs/graphs/` for the Azure equivalent.

For **AWS**, also check which environments are active:
```bash
gh run list --workflow="01-provision-infra.yml" --repo thebyte9/blaze-template-deploy --limit 5
```

### 3. Frugal Reading

- Do **NOT** read the full `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md` automatically here (it should be loaded in `/engage`).
- Do **NOT** read `docs/reference/NETWORK_STACK_RESOURCES.md` completely. Instead use `grep_search` on it to find the specific Resource Naming convention for the service you are about to build.

### 4. Output Summary

Confirm which specific cloud context has been loaded, remind the user of the "No Hardcoding" dynamic namespace rule, and print the active workflow trigger command:

```
✅ Cloud Context Loaded: AWS
Workflow Trigger: gh workflow run "..." --repo thebyte9/blaze-template-deploy --ref dev
Module Hub: thisisblaze/blaze-terraform-infra-core (latest tag: vX.Y.Z)
Stack Locations: dev/stage/prod → blaze-template-deploy | dev-mini → blaze-actions
```
