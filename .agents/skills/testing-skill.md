---
name: Testing Skill
description: A unified testing instruction set for Antigravity agents.
---

# Testing Skill

This skill allows any agent to run the appropriate analysis and testing for the current repository.

## 0. Context Loading (Mandatory)

Before proceeding, you **MUST** read the governance context to ensure compliance with cost and safety rules:
`view_file .antigravity/context/GOVERNANCE.md`

## 1. Detection

The agent must first detect the project type by checking for specific files in the root:

-   **Node.js**: `package.json`
-   **Terraform**: `*.tf` files or `.tflint.hcl`
-   **Go**: `go.mod`

## 2. Execution Instructions

### Node.js (e.g., `blaze-template-deploy`)

1.  **Check for Scripts**: Look at `package.json` `scripts`.
2.  **Run Tests**:
    -   If `test` exists: `npm test`
    -   If `test:unit` exists: `npm run test:unit`
    -   If `test:integration` exists: `npm run test:integration` (Run only if relevant to changes)
3.  **Validation**:
    -   Ensure all tests pass.
    -   If `jest` is used, check coverage reports if available.

### Terraform (e.g., `blaze-terraform-infra-core`)

1.  **Validate**:
    -   Run `terraform validate` in the root of the modified module.
2.  **Lint**:
    -   Run `tflint` if `.tflint.hcl` is present.
    -   Run `terraform fmt -check` to ensure style consistency.

### Hybrid / Other

-   If multiple types are detected, run checks for **all** modified file types.
-   Always check `README.md` or `CONTRIBUTING.md` for custom testing instructions if standard commands fail.

## 3. Reporting

-   Report the command used and the exit code.
-   If tests fail, analyze the output and suggest fixes.
