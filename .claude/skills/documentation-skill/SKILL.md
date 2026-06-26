---
name: Documentation Skill
description: Strict standards for maintaining documentation integrity and structure.
---

# Documentation Skill

This skill enforces the repository's documentation standards, ensuring all docs are fresh, structured, and compliant with governance rules.

## 0. Context Loading (Mandatory)

Before proceeding, you **MUST** read the governance context:
`view_file .antigravity/context/GOVERNANCE.md`

## 1. Structure & Organization

-   **Reports**: MUST be placed in `docs/reports/YYYY/MM/`.
    -   Format: `YYYY-MM-DD-TOPIC.md`
    -   NEVER add loose files to `docs/reports/` root.
-   **Indexes**: Always update `docs/README.md` or the relevant `INDEX.md` when adding new files.
-   **Old Docs**: Move obsolete docs to `docs/archive/`.

## 2. Content Standards

-   **Headers**: Use `H1` (# Title) for the document title.
-   **Metadata**: Include a frontmatter block or top-level list with:
    -   **Date**: YYYY-MM-DD
    -   **Author**: (Agent Name or User)
    -   **Status**: DRAFT / REVIEW / FINAL / DEPRECATED
-   **Terminology**:
    -   Use **Hybrid ECS** (not just "Fargate").
    -   Use **12-Domain Framework**.
    -   Use **5-Killchain Security**.

## 3. Governance Compliance

-   **Read First**: Always read `docs/AI_CONTEXT_GOVERNANCE.md` before writing guides.
-   **Secrets**: NEVER document actual secret values (API keys, passwords). Use placeholders like `<SECRET_NAME>`.
-   **Cost Warnings**: If documenting expensive resources (NAT Gateways, large instances), add a explicit **COST WARNING** block.

## 4. Verification

Before finalizing any document update:
1.  Run `validate-docs.sh` (if available) to check for misplaced files.
2.  Grep for banned terms (e.g., `AWS_ACCESS_KEY_ID` with a value).
