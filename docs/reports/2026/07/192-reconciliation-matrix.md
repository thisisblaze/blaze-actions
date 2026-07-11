# Plan 192 Reconciliation Matrix

This matrix classifies the divergent commits between `dev` and `main` branches.

## Context
- `main`-only commits: 120 (All SHIPPED and validated via v2.11.52. All are **KEEP** automatically).
- `dev`-only commits: 56.

## `dev`-only Commits Classification

### KEEP (Unique functional work to retain)
- `032e523` feat(calculate-config): support IMAGE_PROJECT_KEY_OVERRIDE (Not present on main).
- `064a303` fix(workflows): fix bash word splitting bug in DNS verify by using while-read loop (Strict correctness fix not on main).
- `7214e77` fix(deploy): prevent deploy jobs from skipping when build jobs are intentionally skipped (Not present on main).
- `ed907ee` / `b7616d7` / `2a48276` / `7591ec3` fix: STRICT dynamic ACM resolution (Strict correctness improvement vs main's naive awk. Operator sign-off approved).

### DUPLICATE / OVERRIDDEN BY MAIN (Same intent solved on both sides, shipped `main` variant wins)
- `60de847` / `4d7d6ac` fix(deploy): ECR sub-path and task role naming -> Overridden by `main`'s `09ca2dc` which is the validated shipped fix.
- `f594660` / `d06e05a` / `1370a8c` / `c5b2dba` / `c54db00` / `6269d41` id-token/permissions fixes -> Overridden by `main`'s Plan 164 job-level `id-token` scoping. We pick `main`'s strategy here.
- `4ac5754` fix(workflows): replace floating @main ref with local relative ref -> Overridden by `main`'s hermetic pinning logic from Plan 188.
- `5e9936d` fix(workflows): revert composite actions to fully-qualified cross-repo paths -> Overridden by `main` which already addresses hermeticity and fully-qualified paths.

### NOISE (Ignore)
- 31 `chore: update CHANGELOG for...` commits.
