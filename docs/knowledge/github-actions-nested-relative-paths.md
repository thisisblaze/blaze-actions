---
Last Updated: 2026-03-18
Owner: Infrastructure Team
---

# GitHub Actions Nested Relative Paths Across Organizations

## Topic

When a caller workflow in one repository (`Repo A`) calls a reusable workflow in another repository (`Repo B`), and that reusable workflow attempts to call a secondary, internal workflow inside `Repo B` using a relative path (`uses: ./.github/workflows/internal.yml`), GitHub Actions fatally crashes with `workflow was not found`.

## Context

GitHub Actions natively supports relative path resolution (`./.github/workflows/...`) for internal workflows to simplify version tracking and allow developers to test changes inside pull requests without hardcoding branch names. 

However, there is a fundamental, heavily documented architectural flaw in GitHub's execution engine regarding cross-organization or cross-repository inner-source execution. When traversing a repository boundary, the GitHub Actions parser loses its local context. Consequently, when it evaluates `Uses: ./.github/workflows/internal.yml` inside `Repo B`, it attempts to resolve `./` against the **root caller repository** (`Repo A`) instead of the local repository (`Repo B`). 

Since `Repo A` does not contain the internal scaffolding of `Repo B`, the parser immediately drops the execution plan and throws a `workflow was not found` syntax error, completely halting the queue.

## Symptoms & Debugging Traps

1. **False Positives in local Linters:** `actionlint` and local YAML parsers will always evaluate the schema as 100% syntactically valid, because the issue is entirely tied to the server-side runtime resolution engine.
2. **Masked Errors:** Since GitHub Actions parses workflow jobs either alphabetically or sequentially, if another job physically located above the nested path call contains a fatal syntax error, the parser will crash and report *that* error instead. This often leads engineers to mistakenly assume the relative paths were successfully evaluated prior to a breaking change.
3. **Missing Schema Elements vs Missing Files:** A "workflow was not found" error during compilation for a local file *exclusively* points to a path resolution failure. Schema violations (e.g. missing inputs or outputs) generally yield verbose schema parsing errors, unlike a silent 'not found' drop.
4. **Secret Limits:** GitHub Actions limits reusable workflows to exactly 100 secrets. Exceeding this limit will trigger a schema error, not a 'not found' error.

## The Fix

The only officially documented, natively immune workaround to secure reusable internal actions and workflows against cross-repository integration is to **strictly utilize absolute paths mapped to specific cryptographic SHAs or persistent Tags** for all internal references.

**Broken (Relative):**
```yaml
jobs:
  provision:
    uses: ./.github/workflows/reusable-terraform.yml
    with:
      cloud_provider: aws
```

**Fixed (Absolute, Tag-Pinned):**
```yaml
jobs:
  provision:
    uses: thisisblaze/blaze-actions/.github/workflows/reusable-terraform.yml@v1.4.7
    with:
      cloud_provider: aws
```

### Automation Implication
Due to the absolute path requirement, developers maintaining the `blaze-actions` library must either:
1. Maintain internal workflows using a rolling branch pointer (e.g. `@dev`) for active development, and execute a mass `sed` replacement script to lock all internal pointers to an absolute Tag (`@v1.x.x`) immediately before cutting a production release.
2. Or use an automated release workflow to bump the internal string references continuously.
