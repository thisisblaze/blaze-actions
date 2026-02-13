---
name: Style Guide Skill
description: A unified style guide for Antigravity agents.
---

# Style Guide Skill

This skill enforces coding standards and consistency across all repositories.

## 0. Context Loading (Mandatory)

Before proceeding, you **MUST** read the governance context:
`view_file .antigravity/context/GOVERNANCE.md`

## 1. Code Formatting & Linting

### Node.js / JavaScript
-   **Linter**: Run `npm run lint` if available.
-   **Formatter**: Use Prettier if configured.
-   **Standard**: Follow Airbnb style (as seen in `blaze-template-deploy`).

### Terraform
-   **Formatter**: Always run `terraform fmt -recursive`.
-   **Linter**: Use `tflint` with AWS plugin rules.
-   **Naming**: Use snake_case for resources and variables.

## 2. Commit Messages

All agents must follow **Conventional Commits**:

-   `feat: description` (New features)
-   `fix: description` (Bug fixes)
-   `docs: description` (Documentation changes)
-   `chore: description` (Maintenance, deps)
-   `refactor: description` (Code restructuring)
-   `test: description` (Adding missing tests)

**Example**: `feat(auth): add login endpoint validation`

## 3. Documentation

-   **Keep Docs in Sync**: If code logic changes, check `docs/` for relevant files to update.
-   **Markdown**: Use standard Markdown. Headers should have a space after `#`.
-   **Comments**: Add JSDoc/block comments for complex logic.

## 4. Specific Repository Rules

-   **blaze-template-deploy**:
    -   Strict ESLint rules.
    -   Jest tests are mandatory for new features.
-   **blaze-terraform-infra-core**:
    -   Modules must have `README.md`.
    -   Variables must have `description` and `type`.
