# Claude Code Optimization Plan — blaze-actions (Shared CI/CD Engine)

> [!TIP]
> **Status: SCALED (Multi-Tenant V2).** This is a **shared, open parent repo**
> consumed by many tenants. Every change here must stay tenant-agnostic — no
> hardcoded AWS profiles, no tenant secrets, no tenant repo names.
>
> **Scope**: Claude side only. Antigravity 2.0 config (`.agents/`, sidecars,
> Gemini) is handled separately by the operator. The canonical reference for
> this work is `blaze-template-deploy/docs/plans/175_claude_code_optimization.md`.

---

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED-HIGH (this repo's workflows run in every tenant's CI; a bad
  reusable workflow propagates everywhere)
- **Domain**: ci | security | cost | dx
- **Planned at**: `2026-06-25`
- **Status**: PROPOSED

---

## Why this matters

`blaze-actions` is the CI/CD engine: it owns `agent-pr-review.yml` (the
reusable architecture-review workflow tenants call) and
`reusable-incident-triage.yml`. Because every tenant inherits these, this repo
is where the **Claude-in-CI** posture is actually defined. It also has the
largest `.github/workflows/` surface (60+ files) and the most room for
least-privilege and version-pin hygiene.

Gaps found:

1. **`agent-pr-review.yml` pins `blaze-conductor` to a bare SHA**
   (`5141a3d6…`) with no comment tying it to a release tag — hard to audit
   which conductor version tenants actually run.
2. **No `.claude/settings.json`** in this repo at all → no permission rules, no
   hooks, no security plugin. Contrast with `blaze-template-deploy` which has
   them. A maintainer running Claude here has zero guardrails.
3. **Skills/subagents live under `.agents/skills/` only.** Claude Code loads
   skills from `.claude/skills/` and subagents from `.claude/agents/`; the
   `.agents/` tree is the Antigravity path. So the infrastructure/testing/style
   skills are invisible to Claude Code in this repo.
4. **`.mcp.json` uses `${BLAZE_DOCS_ROOT}`** — same portability issue as the
   tenant repo, and more acute here since CI sets it to
   `${{ github.workspace }}/docs/architecture` which may not contain the
   `servers/` tree the config expects.
5. **No GA-action usage.** Evaluate `anthropics/claude-code-action@v1` for
   maintainer-facing `@claude` requests on this repo's own PRs/issues.

---

## A. GitHub Actions / CI

### A1. Make the conductor pin auditable (security — 15 min)

The reusable `agent-pr-review.yml` checks out conductor at a SHA. Keep SHA
pinning (correct), but annotate it with the release tag it corresponds to and
add a one-line guard so a stale pin is visible:

```yaml
# .github/workflows/agent-pr-review.yml
       - name: Checkout blaze-conductor
         uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
         with:
           repository: thisisblaze/blaze-conductor
           token: ${{ secrets.GH_PAT }}
           path: .conductor
-          ref: 5141a3d6b5ff454759aecaadf6fd112b1ba2d09e
+          ref: 5141a3d6b5ff454759aecaadf6fd112b1ba2d09e   # == blaze-conductor vX.Y.Z (keep tag+SHA in sync)
```

Document the SHA↔tag mapping in `docs/REUSABLE_WORKFLOWS.md` so tenants can see
what they run. When conductor cuts a new release, bump the SHA **and** the
comment in the same PR.

### A2. Cut the canonical tag the tenants expect

`blaze-template-deploy/CLAUDE.md` pins `blaze-actions@v2.11.5`, but tenant
callers still reference `@v2.11.2`. Reconcile from the producer side:

```bash
git tag --list "v2.11.*" --sort=-v:refname | head
# If v2.11.5 is not yet cut and the canonical pin says it should be:
#   run the /03-version-release workflow (do NOT hand-tag) to cut it,
#   then tenants bump their callers (template-deploy Plan 175 §A1).
```

> **STOP**: tags are immutable here (VERSIONING discipline). Never delete or
> move a tag. If the canonical pin is wrong, fix the pin, don't rewrite history.

### A3. Standardize on `ANTHROPIC_API_KEY`

The reusable workflows here correctly use `ANTHROPIC_API_KEY` /
`secrets.GH_PAT`. Confirm none of the 60+ workflows use the legacy
`CLAUDE_API_KEY` (conductor does — fix there):

```bash
grep -rn "CLAUDE_API_KEY" .github/ && echo "FIX" || echo "OK"
```

### A4. Decision — GA action vs bespoke (per your "evaluate both" choice)

| Need | Verdict |
|---|---|
| Tenant PR **architecture** review (mirror rule, pins, naming) | **Keep bespoke** `agent-pr-review.yml` + conductor orchestrator. Domain logic the GA action can't replicate. |
| Maintainer `@claude` fix/answer on **this repo's** issues/PRs | **Add GA action** (`claude-code-action@v1`) — workflow-authoring help, YAML fixes. |
| Self-review of changed workflow YAML for security | **Add GA action** running the bundled `/code-review` (or the official `code-review` plugin) on `pull_request`. |

Ready-to-apply self-review workflow (uses the official action's plugin path):

```yaml
# .github/workflows/claude-workflow-review.yml  (NEW)
name: Claude Workflow Review
on:
  pull_request:
    paths: [".github/workflows/**"]
permissions:
  contents: read
  pull-requests: write
concurrency:
  group: claude-wf-review-${{ github.ref }}
  cancel-in-progress: true
jobs:
  review:
    runs-on: ubuntu-latest
    timeout-minutes: 12
    steps:
      - uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          plugin_marketplaces: "https://github.com/anthropics/claude-code.git"
          plugins: "code-review@claude-code-plugins"
          prompt: "/code-review:code-review ${{ github.repository }}/pull/${{ github.event.pull_request.number }}"
          claude_args: "--max-turns 8 --model claude-sonnet-4-6"
```

> This complements, not replaces, `actionlint` / `validate-workflows.yml`.

---

## B. Local dev config (`.claude/`)

### B1. Add `.claude/settings.json` (currently missing)

Mirror the tenant repo's guardrails, adapted: this repo edits **workflow YAML
and shell**, not live Terraform, so deny destructive shell + protect the
release machinery.

```jsonc
// .claude/settings.json  (NEW)
{
  "permissions": {
    "defaultMode": "plan",
    "deny": [
      "Bash(git push*--force*)",
      "Bash(git tag -d*)",
      "Bash(gh release delete*)",
      "Bash(terraform destroy*)",
      "Bash(aws *delete*)"
    ],
    "allow": [
      "Bash(actionlint*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(gh pr view*)",
      "Bash(gh workflow view*)"
    ]
  },
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

> Tag immutability is policy, but a deny rule on `git tag -d` / `git push
> --force` makes it enforced, not just advisory.

### B2. Make this repo's skills usable by Claude Code

`.agents/skills/{infrastructure,testing,documentation,style-guide}` are the
Antigravity copies. Expose them to Claude Code without duplicating content via
symlinks (Claude resolves symlinks in `.claude/`):

```bash
mkdir -p .claude/skills
# one SKILL.md per skill dir is what Claude Code expects; link the dirs:
ln -s ../../.agents/skills/infrastructure-skill .claude/skills/infrastructure 2>/dev/null || true
ln -s ../../.agents/skills/testing-skill        .claude/skills/testing        2>/dev/null || true
ln -s ../../.agents/skills/style-guide          .claude/skills/style-guide    2>/dev/null || true
# Verify each target dir contains a SKILL.md with name/description frontmatter;
# if it's a flat .md, wrap it: .claude/skills/<name>/SKILL.md
```

> **STOP / check**: confirm the link targets actually contain a `SKILL.md`
> with YAML frontmatter (`name`, `description`). If they're plain `.md` rule
> files, create thin `SKILL.md` wrappers instead of linking — a skill without
> frontmatter won't load.

### B3. Per-edit security patterns for this repo

Workflow files can grant repo-level permissions — the security plugin already
flags edits under `.github/workflows/`. Add CI-specific patterns:

```yaml
# .claude/security-patterns.yaml  (NEW)
patterns:
  - rule_name: unpinned_action
    regex: "uses:\\s+[^@\\n]+@(main|master|v\\d+)\\s*$"
    paths: [".github/workflows/**"]
    reminder: "Pin third-party actions to a full SHA, not a branch or floating major."
  - rule_name: broad_pat_scope
    substrings: ["permissions: write-all"]
    reminder: "Use least-privilege permissions blocks, never write-all."
  - rule_name: hardcoded_tenant
    regex: "(thisisblaze|blazecms)\\b"
    paths: ["**/*.yml", "**/*.yaml"]
    reminder: "This is a shared repo — no hardcoded tenant names in reusable workflows."
```

---

## C. Context & cost optimization

- **`.mcp.json` portability.** Same `${BLAZE_DOCS_ROOT}` issue. For local
  maintainer sessions, document the export in `README.md` / `.envrc`. In CI,
  the linters only matter inside the conductor orchestrator step (which sets
  its own `BLAZE_DOCS_ROOT`), so consider **not** shipping `.mcp.json` reliance
  for plain edits here — an unresolved server reconnect invalidates the local
  cache mid-session.
- **CLAUDE.md is 19 lines** — good, leave it. Rules import the same five files
  as the other repos; `roles.md` can be `paths:`-scoped to
  `.agents/workflows/**` here too (this repo rarely needs the 5-role model in a
  plain YAML edit).
- **CI cost guardrails** for any GA-action workflow: `--max-turns` +
  `timeout-minutes`, Sonnet not Opus for routine work. The bespoke orchestrator
  already caps diffs at 8 KB.
- **Prompt caching for the orchestrator**: if `pr-architecture-review.js` sends
  a large static rule/context block every PR, that's where a `cache_control`
  breakpoint pays off — but the script lives in **blaze-conductor**, so that
  change belongs to the conductor plan. Flagged here as the caller.

---

## D. Security hardening

1. Enable the security-guidance plugin (§B1) — high value here because edits to
   `.github/workflows/**` are exactly its workflow-file check category.
2. Add `.claude/claude-security-guidance.md`:

   ```markdown
   <!-- .claude/claude-security-guidance.md (NEW) -->
   # Security guidance for blaze-actions (shared CI engine)
   - Pin all third-party actions to a full commit SHA.
   - Reusable workflows must not hardcode tenant names, profiles, or secrets.
   - Every job sets an explicit least-privilege `permissions:` block.
   - Never echo `secrets.*` into logs or step outputs.
   - Tags are immutable: never delete or move a released tag.
   ```

3. **Audit `permissions:` blocks across all jobs** (the repo already did a SHA-
   pinning pass per template-deploy Plan 162; extend that discipline to Claude
   workflows): no `write-all`, `id-token: write` only where OIDC is used.
4. Keep the conductor checkout token (`GH_PAT`) scoped to read-only on the
   conductor repo if a fine-grained PAT is feasible.

---

## Verification

```bash
# 1. No legacy secret name
grep -rn "CLAUDE_API_KEY" .github/ && echo "FIX" || echo "OK"
# 2. No floating refs for internal repos
grep -rn "ref:\s*\(main\|master\)" .github/workflows/ && echo "FIX" || echo "OK"
# 3. settings valid
jq . .claude/settings.json >/dev/null && echo "OK"
# 4. skills load (manual): claude → /skill  → infrastructure/testing/style appear
# 5. actionlint still passes on any new workflow
actionlint .github/workflows/claude-workflow-review.yml
```

> Final QA: run the new `claude-workflow-review.yml` against its own
> introducing PR (dogfood), and confirm a fresh-context subagent review finds
> no least-privilege regressions.

---

## STOP conditions

- Cutting/moving a tag by hand → use `/03-version-release`; tags are immutable.
- A `.claude/skills/*` symlink target has no `SKILL.md` frontmatter → wrap it,
  don't link a bare rule file.
- Any reusable workflow change that bakes in a tenant name or profile → stop;
  this repo must stay agnostic.
