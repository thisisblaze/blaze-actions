# Changelog

All notable changes to the `blaze-actions` project will be documented in this file.

## [Unreleased]
- feat(v2-audit): **Plan 207** — Removed 5.8MB actionlint binary, relocated 17 root maintenance scripts to `scripts/maintenance/`, enforced `timeout-minutes: 30` across 29 jobs in 8 workflows, and aligned branch parity with `dev` and `main`. (2026-07-24)

## v2.12.17 (2026-07-23)

### Added

- feat: whitespace-normalize confirmation gates in ops workflows (#192)

### Changed

- chore: delete stale live/ duplicate mirrors and sync docs sweep
- chore: update CHANGELOG for v2.12.15
- chore: update CHANGELOG for v2.12.14
- chore: update CHANGELOG for v2.12.13
- chore: update CHANGELOG for v2.12.12

### Fixed

- fix: correct botched previous commit (accidental base64 paste)
- fix(mongo): require explicit tls=true for flex-tier mongodb:// scheme
- fix(provision-db-users): pick mongodb:// vs mongodb+srv:// based on host shape (#185)
- fix: eliminate all remaining grouping parenthesis logical issues
- fix: resolve grouping parenthesis syntax in all workflows
- fix: remove logical grouping parenthesis from cleanup conditional expressions

## v2.12.16 (2026-07-23)

### Added

- **feat(deploy): minimum `desired_count` floor (1) in `deploy-ecs-service`** (`.github/actions/deploy-ecs-service/action.yml`, Plan 324 Phase 3). Added an automatic pre-deployment check that queries live service `desiredCount`. If a service is scaled down or sleeping (`desiredCount` == 0), the action automatically raises `desiredCount` to 1 prior to task registration, ensuring active deployments do not remain parked at 0 tasks.
- **feat(ci): hermetic `pin-guard` linter in `validate-workflows.yml`** (`.github/workflows/validate-workflows.yml`, Plan 324 Phase 2). Added a dedicated `pin-guard` job that scans all workflows in `.github/workflows/` and fails pull requests if any internal workflow calls reference floating `@main` tags.

### Changed

- **perf(build): native arm64 runner & GHA layer caching** (`.github/workflows/reusable-docker-build.yml`, Plan 324 Phase 1). Verified `ubuntu-24.04-arm` native runners and `type=gha,mode=max` layer caching for Graviton container builds, bypassing QEMU emulation overhead and reducing build durations to under 5 minutes.
- **docs(plan-324): V2 CI/CD Modernization & V3 Feature Adoption** (`docs/plans/324_cicd_v2_modernization_and_v3_adoption_plan.md` & `docs/reports/2026-07-23_cicd_v2_vs_v3_comparison_report.md`). Backported battle-tested V3 (Forge) build performance, deployment resilience, ADR-007 destruction safety, and ADR-017 read-only AI agent triage into the V2 pipeline ecosystem.

### Fixed

- **fix(deploy): prevent sleeping/scaled-to-zero ECS deployments from reporting false completion** (`.github/actions/deploy-ecs-service/action.yml`). Enforces a minimum task floor before triggering ECS task definition stability waits.

## v2.12.15 (2026-07-16)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.14
- chore: update CHANGELOG for v2.12.13
- chore: update CHANGELOG for v2.12.12

### Fixed

- fix: eliminate all remaining grouping parenthesis logical issues
- fix: resolve grouping parenthesis syntax in all workflows
- fix: remove logical grouping parenthesis from cleanup conditional expressions

## v2.12.14 (2026-07-16)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.13
- chore: update CHANGELOG for v2.12.12

### Fixed

- fix: eliminate all remaining grouping parenthesis logical issues
- fix: resolve grouping parenthesis syntax in all workflows
- fix: remove logical grouping parenthesis from cleanup conditional expressions

## v2.12.13 (2026-07-16)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.12

### Fixed

- fix: eliminate all remaining grouping parenthesis logical issues
- fix: resolve grouping parenthesis syntax in all workflows
- fix: remove logical grouping parenthesis from cleanup conditional expressions

## v2.12.12 (2026-07-13)

### Added

- No new features in this release

### Changed

- chore: align checkengines diagnostic checks to support 4-repo setup (including blaze-conductor) (#204)
- docs: deep cicd maintenance sync - 4-repos structure & changelog update
- docs: run /11-maintain-prompts-ai sweep and fix absolute persona links
- docs: run /09-maintain-docs sweep and archive loose reports
- docs: add Unreleased section for GHA boolean quoting fix
- chore: update CHANGELOG for v2.12.11

### Fixed


## [Unreleased]

### Changed
- docs: updated `WORKFLOW_CATALOG.md` and `REUSABLE_WORKFLOWS.md` to remove legacy `95-cleanup-orphaned-data.yml` and correct outdated stress-test documentation. (2026-07-11)
- chore: updated `.agents/workflows/13-deep-cicd-maintenance.md` and `allstop.md` to reference modern `reusable-stress-test-provision-minimal.yml` and `08-stress-test-suite.yml`, and updated modified file timestamps to `2026-07-11`. (2026-07-11)

### Fixed
- fix(nuke): quote raw boolean `apply` and `destroy` inputs to matching string types in reusable GHA calls to prevent GHA compiler-time validation errors.
- docs: convert absolute links to relative paths in agent workflows to prevent broken file links across workspaces.
- docs: execute weekly visual graph verification sweep, refreshing outdated mermaid diagrams and updating MAINTENANCE_STATE.md.

## v2.12.11 (2026-07-10)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.10

### Fixed


## v2.12.10 (2026-07-10)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.9

### Fixed


## v2.12.9 (2026-07-10)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.8

### Fixed


## v2.12.8 (2026-07-10)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.7

### Fixed


## v2.12.7 (2026-07-10)

### Added
- feat(nuke): consolidate multi-mode AWS nuke logic from local `99-nuke-env.yml` into master `99-ops-nuke.yml`.

### Changed
- chore(nuke): support custom inputs `nuke_mode`, `project`, and `projects` with optional secrets in master nuke workflow.
- chore(nuke): update concurrency configuration to support mutual exclusion across different nuke modes.
- chore(nuke): add safety guards (`inputs.nuke_mode == ''`) to standard jobs to preserve persistent state (databases/data stores).
- chore: end-of-day governance sync — 2026-07-10
- chore: update CHANGELOG for v2.12.6

### Fixed
- fix(nuke): fix typo in verify-destroy-complete needs checks referencing the old nuke-cleanup-dns job.

## v2.12.6 (2026-07-08)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.5
- chore: update CHANGELOG for v2.12.4

### Fixed


## v2.12.6 (2026-07-08)

### Fixed
- fix(reusable-provision-db-users): downgrade customDBRoles API endpoint from v2 to v1.0, bypassing 406 Accept Header validation rejections from MongoDB Atlas.

## v2.12.5 (2026-07-08)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.4

### Fixed


## v2.12.4 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.3
- chore: update CHANGELOG for v2.12.3

### Fixed


## v2.12.3 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.3

### Fixed


## v2.12.3 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.2
- chore: update CHANGELOG for v2.12.1
- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: end-of-day governance sync — 2026-07-06
- chore: update CHANGELOG for v2.11.55
- chore: add sync-skills.mjs for cross platform portability
- chore: implement cross-platform portability plan for macOS and Windows

### Fixed

- fix: conditionally add-mask for ELASTIC_ADMIN_PASS to avoid empty string warning
- fix: update custom db role to inherit readWrite and patch on conflict
- fix: correct Atlas customDBRoles API endpoint

## v2.12.2 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.1
- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: end-of-day governance sync — 2026-07-06
- chore: update CHANGELOG for v2.11.55
- chore: add sync-skills.mjs for cross platform portability
- chore: implement cross-platform portability plan for macOS and Windows

### Fixed

- fix: conditionally add-mask for ELASTIC_ADMIN_PASS to avoid empty string warning
- fix: update custom db role to inherit readWrite and patch on conflict
- fix: correct Atlas customDBRoles API endpoint

## v2.12.1 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: end-of-day governance sync — 2026-07-06
- chore: update CHANGELOG for v2.11.55
- chore: add sync-skills.mjs for cross platform portability
- chore: implement cross-platform portability plan for macOS and Windows

### Fixed

- fix: conditionally add-mask for ELASTIC_ADMIN_PASS to avoid empty string warning
- fix: update custom db role to inherit readWrite and patch on conflict
- fix: correct Atlas customDBRoles API endpoint

## v2.12.0 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.0
- chore: update CHANGELOG for v2.12.0
- chore: end-of-day governance sync — 2026-07-06
- chore: update CHANGELOG for v2.11.55
- chore: add sync-skills.mjs for cross platform portability
- chore: implement cross-platform portability plan for macOS and Windows

### Fixed

- fix: conditionally add-mask for ELASTIC_ADMIN_PASS to avoid empty string warning
- fix: update custom db role to inherit readWrite and patch on conflict
- fix: correct Atlas customDBRoles API endpoint

## v2.12.0 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.12.0
- chore: end-of-day governance sync — 2026-07-06
- chore: update CHANGELOG for v2.11.55
- chore: add sync-skills.mjs for cross platform portability
- chore: implement cross-platform portability plan for macOS and Windows

### Fixed

- fix: conditionally add-mask for ELASTIC_ADMIN_PASS to avoid empty string warning
- fix: update custom db role to inherit readWrite and patch on conflict
- fix: correct Atlas customDBRoles API endpoint

## v2.12.0 (2026-07-07)

### Added

- No new features in this release

### Changed

- chore: end-of-day governance sync — 2026-07-06
- chore: update CHANGELOG for v2.11.55
- chore: add sync-skills.mjs for cross platform portability
- chore: implement cross-platform portability plan for macOS and Windows

### Fixed

- fix: conditionally add-mask for ELASTIC_ADMIN_PASS to avoid empty string warning
- fix: update custom db role to inherit readWrite and patch on conflict
- fix: correct Atlas customDBRoles API endpoint

## v2.11.55 (2026-07-06)

### Added

- No new features in this release

### Changed

- chore: governance sync and MCP orchestrator pin update
- chore: update CHANGELOG for v2.11.55
- chore: update CHANGELOG for v2.11.54

### Fixed

- fix: repin conductor to latest main SHA

## v2.11.55 (2026-07-06)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.54

### Fixed


## v2.11.54 (2026-07-06)

### Added

- No new features in this release

### Changed

- chore: end-of-day governance sync
- chore: update CHANGELOG for v2.11.53

### Fixed


## [Unreleased]

- chore: end-of-day governance sync — 2026-07-05

## v2.11.53 (2026-07-05)

### Added

- Merge pull request #182 from thisisblaze/feat/backlog-idtoken-scope
- Merge pull request #181 from thisisblaze/feat/followup-161-pipefail
- feat: implement wipe-state for aws
- feat: configure dev-mini explicitly for CI parity (#72)

### Changed

- chore: update CHANGELOG for v2.11.52
- chore: update CHANGELOG for v2.11.51
- chore: update CHANGELOG for v2.11.50
- chore: update CHANGELOG for v2.11.49
- chore: update CHANGELOG for v2.11.48
- chore: update CHANGELOG for v2.11.47
- chore: end-of-day governance sync — 2026-07-04
- chore: use @main instead of @v2.11.20
- chore: end-of-day governance sync — 2026-06-27
- Merge pull request #169 from thisisblaze/dev
- chore: bump third-party module pins to v2.11.2 (#165)
- chore: bump third-party module pins to v2.11.2 (#164)
- docs: add cleanup-orphaned-data to WORKFLOW_CATALOG (#163)
- chore: release v2.11.16
- chore: sync dev into main for v2.11.16
- chore: sync dev into main for v2.11.15 (#155)
- chore: sync dev into main (#153)
- chore: minor comment update in provision-infra to ensure fresh validation (#118)
- chore: revert workflows to v2.11.6 to undo ruamel formatting corruption
- chore: end-of-day governance sync — 2026-06-23

### Fixed

- fix: remove invalid permissions block from uses job
- fix: add missing secrets to dns handoff workflows
- fix: remove shellcheck from pre-apply hook
- fix: remove permissions from auto-cleanup-dns uses job
- fix: restore global id-token permissions
- fix: correct boolean coercion in reusable workflow inputs
- fix: remove environment from debug and config
- fix: remove duplicate EC_API_KEY
- fix: add missing EC_API_KEY secret
- fix: dev environment option in 99-ops-terraform
- fix: pass EC_API_KEY to pre_apply script env on main (#152)
- fix: replace secrets: inherit with explicit mapping to prevent cross-org startup failure (#140)
- fix: resolve nested workflow startup failures in stress test suite (#139)
- fix: resolve startup_failure by declaring missing input dns_record_name in 99-ops-utility (#136)
- fix: actually point stress test to v8 (perfect shell) (#135)
- fix: convert boolean inputs in 99-ops-utility to string + restore provision chain (#126)
- fix: remove extra secrets from provision-minimal callee (not defined in provision-infra-minimal) (#117)
- fix: remove extra cloud_provider from provision-minimal callee (#116)
- fix: remove stack input from provision-minimal (provision-infra-minimal has no stack input) (#115)
- fix: convert boolean literals and types to string in provision-minimal (#114)
- fix: change literal boolean apply: true to string apply: 'true' in provision (#112)
- fix: remove boolean literal comparisons (== true) from if conditions in provision-infra (#111)
- fix: align workflow_dispatch and workflow_call input types in provision-infra (#109)
- fix: explicit ternary for apply/destroy/vpc_peering to resolve WD vs WC type conflict (#108)
- fix: convert boolean comparison expressions to string ternaries in provision-infra (#107)
- fix: convert boolean expressions to string in stress-test-provision (#105)
- fix: convert all boolean inputs to string in terraform chain to resolve startup_failure (#104)
- fix: revert provision internal refs back to @main to use type:string fixes (#87)
- fix: change expression-evaluated boolean inputs to string type to fix startup_failure (#86)
- fix: revert internal refs in provision to @v2.11.6 (#84)
- fix: remove duplicated type definition in mode inputs
- fix: add missing type string to mode inputs in reusable workflows
- fix: use @main for internal workflow references to resolve missing secrets
- fix: add secrets directly to v2.11.6 workflows safely
- fix: remove newline from github actions expressions broken by ruamel
- fix: remove newline from uses directives broken by ruamel (#82)
- fix: remove top-level permissions from reusable workflows

## v2.11.52 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.51
- chore: update CHANGELOG for v2.11.50
- chore: update CHANGELOG for v2.11.49
- chore: update CHANGELOG for v2.11.48
- chore: update CHANGELOG for v2.11.47

### Fixed


## v2.11.51 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.50
- chore: update CHANGELOG for v2.11.49
- chore: update CHANGELOG for v2.11.48
- chore: update CHANGELOG for v2.11.47

### Fixed


## v2.11.50 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.49
- chore: update CHANGELOG for v2.11.48
- chore: update CHANGELOG for v2.11.47

### Fixed


## v2.11.49 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.48
- chore: update CHANGELOG for v2.11.47

### Fixed


## v2.11.48 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.47

### Fixed


## v2.11.47 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.46

### Fixed


## v2.11.46 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.46
- chore: update CHANGELOG for v2.11.45

### Fixed


## v2.11.45 (2026-07-05)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.44
- chore: update CHANGELOG for v2.11.43
- chore: update CHANGELOG for v2.11.43

### Fixed

- fix: STRICT dynamic ACM resolution requires BOTH apex and wildcard SANs

## v2.11.44 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.43
- chore: update CHANGELOG for v2.11.43

### Fixed

- fix: STRICT dynamic ACM resolution requires BOTH apex and wildcard SANs

## v2.11.43 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.43

### Fixed


## v2.11.42 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.42

### Fixed


## v2.11.41 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.40

### Fixed

- fix: STRICT dynamic ACM resolution (ISSUED + wildcard SANs)

## v2.11.40 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.39

### Fixed


## v2.11.39 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.38

### Fixed


## v2.11.38 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.37

### Fixed


## v2.11.37 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.36

### Fixed


## v2.11.36 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.35

### Fixed


## v2.11.35 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.34
- chore: update CHANGELOG for v2.11.33

### Fixed


## v2.11.34 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.33

### Fixed


## v2.11.33 (2026-07-04)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.11.32

### Fixed


## v2.11.32 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.32
- chore: update CHANGELOG for v2.11.32
- chore: update CHANGELOG for v2.11.32
- chore: update CHANGELOG for v2.11.31
- chore: update CHANGELOG for v2.11.30
- chore: update CHANGELOG for v2.11.29
- chore: update CHANGELOG for v2.11.28
- chore: update CHANGELOG for v2.11.27
- chore: update CHANGELOG for v2.11.26
- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.31 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.30
- chore: update CHANGELOG for v2.11.29
- chore: update CHANGELOG for v2.11.28
- chore: update CHANGELOG for v2.11.27
- chore: update CHANGELOG for v2.11.26
- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.30 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.29
- chore: update CHANGELOG for v2.11.28
- chore: update CHANGELOG for v2.11.27
- chore: update CHANGELOG for v2.11.26
- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.29 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.28
- chore: update CHANGELOG for v2.11.27
- chore: update CHANGELOG for v2.11.26
- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.28 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.27
- chore: update CHANGELOG for v2.11.26
- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.27 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.26
- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.26 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.25
- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.25 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.24
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.24 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.23 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.23
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.22 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: update CHANGELOG for v2.11.22
- chore: update CHANGELOG for v2.11.21
- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## v2.11.21 (2026-07-04)

### Added

- feat: implement Plan 189 CI/CD hardening guards 1, 3, 4 (#180)

### Changed

- chore: end-of-day governance sync — 2026-07-03
- chore: end-of-day governance sync — 2026-07-02
- chore: update CHANGELOG for v2.11.20

### Fixed


## Unreleased

### Fixed

- fix(health): restore FREEZE-annotated drift-check pins in `90-daily-health-check.yml` to `@v2.1.74`. The v2.11.20 `@main` un-floating sweep incorrectly bumped these two intentional chaos-test pins to the current release tag, which triggers a GitHub Actions self-referencing loop (`startup_failure`). `checkengines` engine4 skips `FREEZE` lines, so this was not caught automatically.
- fix(ci): fixed broken `elastic` stack variables and bumped third-party data stack infra-core refs to canonical `v2.11.4` (Plan 178 Phase 2)

## v2.11.20 (2026-07-02)

### Added

- No new features in this release

### Changed

- chore: release v2.11.20
- chore: update CHANGELOG for v2.11.19

### Fixed

- fix: add task role naming fallback in ecs deploy action

## v2.11.19 (2026-06-27)

### Added

- No new features in this release

### Changed


### Fixed

- fix: add task role naming fallback in ecs deploy action

## [Unreleased]

## v2.11.16 (2026-06-26)
### Added
- feat(ci): `third-party/{mongodb,elastic}/pre_apply.sh` now emit a single greppable outcome line `PRE_APPLY_RESULT[<component>]=<TOKEN>` (+ GitHub `::notice::` + run-summary row) at every exit path — tokens `IMPORTED / NO_ORPHAN / ALREADY_IN_STATE / IMPORT_FAILED / SKIPPED_*`. Makes the Plan 176 import smoke test assertable from logs.
- feat(ci): `cleanup-orphaned-data.sh` emits a greppable `CLEANUP_RESULT=<CLEAN|ORPHANS_DETECTED|ORPHANS_TERMINATED|ORPHANS_PARTIAL>` line (+ `::notice::` + run-summary Result row) for monitoring/alerting on the nightly sweep.
- feat(ci): **Plan 177 Phase 1** — operationalized orphan reconciliation. `cleanup-orphaned-data.sh` hardened: Elastic now reconciles by **deployment ID** (names are not unique in Elastic Cloud — fixes detection of duplicate orphans), sweep is **stage-scoped** (state buckets are per-stage), and posts an optional Slack alert (`SLACK_WEBHOOK_URL`) when orphans are found. `99-ops-utility.yml` passes `STAGE` + `SLACK_WEBHOOK_URL` into the cleanup job.
- feat(ci): **Plan 176** — orphan protection for third-party data stacks. Added `pre_apply.sh` to `third-party/mongodb` and `third-party/elastic` (AWS live stacks): on a non-destroy run they probe the Atlas/Elastic API for a name-matched cluster absent from state and `terraform import` it, preventing duplicate creation after a cancelled apply. Added `cleanup-orphaned-data` action to `99-ops-utility.yml` (+ `.github/scripts/cleanup-orphaned-data.sh`) which reconciles live Atlas clusters / EC deployments against S3 state and terminates in-scope orphans — scoped to the tenant `<namespace>-<client_key>-` prefix, dry-run by default, live deletes gated by a typed `DESTROY-<env>-<stack>` confirmation.

### Changed
- feat: `calculate-config` now natively derives infrastructure routing (`DB_TIER`, `ELASTIC_TIER`, `DEDICATED_ALB`, etc.) from `PROJECT_TIER` and `POD` inputs, centralizing the environment capacity tier mapping (Plan 168).

## v2.10.5 (2026-06-21)

### Changed
- chore: end-of-day governance sync — 2026-06-21
- docs: added branch protection and governance rules
- build: bump terraform module dependencies to v2.10.1

## v2.10.4 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.10.3

### Fixed

- fix: restored secrets block to 99-ops-utility to resolve startup_failure in CI engine

## v2.10.3 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.10.2
- chore: update CHANGELOG for v2.10.1
- chore: update CHANGELOG for v2.10.0

### Fixed


## v2.10.2 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.10.1
- chore: update CHANGELOG for v2.10.0

### Fixed


## v2.10.1 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.10.0

### Fixed


## v2.10.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.10.0
- chore: release v2.10.0
- chore: end-of-day governance sync — 2026-06-17
- chore: end-of-day governance sync — 2026-06-17
- chore: end-of-day governance sync — 2026-06-17
- chore: update CHANGELOG for v2.7.9
- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.7
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0

### Fixed


## v2.10.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: release v2.10.0
- chore: end-of-day governance sync — 2026-06-17
- chore: end-of-day governance sync — 2026-06-17
- chore: end-of-day governance sync — 2026-06-17
- chore: update CHANGELOG for v2.7.9
- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.7
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0

### Fixed


## [v2.10.0] - 2026-06-17

### Added
- feat(cicd) (Plan 158 §3.2): `02-deploy-pages.yml` gains native static-SPA admin paths — GCP `deploy-admin-gcs` (GCS rsync + Cloud CDN invalidation) and opt-in Azure `deploy-admin-azure-blob` (Blob `$web` upload + Front Door purge), gated by new `static_admin_target` input (default `cloudflare`). Job-level `id-token: write`. Assumes infra targets exist; CDN/Front-Door purge is best-effort.
- feat(ci): add `node:test` based smoke fixture for post-deployment gating in AWS, Azure, and GCP.
- feat(cicd) (Plan 169 / L21): add `97-ops-maintenance.yml` reusable workflow — resolves cluster via `calculate-config`, runs the post-reprovision compile gate over ECS Exec, optional CloudFront invalidation.
- feat(cicd): Updated `reusable-pre-destroy-cleanup.yml` with GCP/Azure orphaned resource cleanups (GCS empty, NEG delete, Secrets delete, Azure Front Door & empty blob).

### Changed
- chore(cicd): Upgraded `blaze-terraform-infra-core` references to `v2.10.0` globally.
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
- fix(security): scoped OIDC token write permissions strictly to the jobs that require them, removing them from generic utility tasks.

### Fixed
- fix(cicd): make `97` compile gate actually gate failures — install `session-manager-plugin` (absent on `ubuntu-latest`), assert a split success sentinel since `execute-command` returns the SSM session exit code rather than the remote command's, `set -euo pipefail`, drop unused `actions: write` permission.
## v2.7.9 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.7
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.8 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.8
- chore: update CHANGELOG for v2.7.7
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.8 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.7
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.7 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.6 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.6
- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.6 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.5
- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.5 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.4
- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.4 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.3
- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.3 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.2
- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.2 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.1
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.1 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-17)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-16)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.7.0
- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials

## v2.7.0 (2026-06-15)

### Added

- feat: accept tf_vars input for reusable dns handoff
- feat: reusable dns handoff workflows
- feat: configure bump-terraform-modules script and workflow to use GH_PAT for authentication
- feat: add automated bump-terraform-modules script and workflow

### Changed

- chore: pin internal refs @v2.7.0 for release
- chore: remove stray helper scripts and secrets template
- chore: update CHANGELOG for v2.6.0
- chore: update CHANGELOG for v2.6.0
- chore: end-of-day governance sync — 2026-06-14
- chore: add debug for cloudflare secrets
- chore: end-of-day governance sync — 2026-06-14
- chore: end-of-day governance sync — 2026-06-14
- chore: bump GCP stack infra-core module refs to v2.7.1
- chore: bump infra-core module refs to v2.7.1
- chore: end-of-day governance sync - update CHANGELOG for bump script and workflow
- chore: remove non-existent azure directories from dependabot.yml
- chore: configure dependabot for terraform package-ecosystem
- chore: end-of-day governance sync — 2026-06-13
- chore: bump infra-core module refs to v2.7.0
- chore: dual-tool parity — add Claude Code bootstrap blocks to engage/02-dry-run/03-monitor-stress + CLAUDE.md exclusions
- chore: point reusable-terraform to dev branch for testing
- refactor: remove Cloudflare sanitization from provision workflow
- refactor: remove Cloudflare logic from shared engine
- docs: add NotebookLM educational prompts (infographic + short/long podcast) — 2026-06-03
- chore: clean up transient sync scripts
- chore: end-of-day governance sync — 2026-06-02
- chore: end-of-session governance sync — 2026-06-02
- chore: end-of-day governance sync — 2026-06-02
- chore: end-of-day governance sync — 2026-05-31
- chore: resolve split-brain — bump GHA self-refs v2.1.74→v2.2.2, Terraform pins →v2.6.9
- chore: update CHANGELOG for v2.2.2

### Fixed

- fix: use current branch for calculate-config in 01-provision-infra
- fix: export TF_VAR_default_basic_auth_credentials
- fix: use tr -cd to strictly sanitize Cloudflare secrets
- fix: explicitly map secrets to reusable terraform
- fix: absolute path for nested reusable workflow
- fix: yaml syntax in reusable workflows
- fix: pass Cloudflare secrets to pre-apply script
>>>>>>> origin/dev

## v2.6.0 (2026-06-14)

### Added

- feat: configure bump-terraform-modules script and workflow to use GH_PAT for authentication
- feat: add automated bump-terraform-modules script and workflow

### Changed

- chore: update CHANGELOG for v2.6.0
- chore: end-of-day governance sync — 2026-06-14
- chore: end-of-day governance sync — 2026-06-14
- chore: bump GCP stack infra-core module refs to v2.7.1
- chore: bump infra-core module refs to v2.7.1
- chore: end-of-day governance sync - update CHANGELOG for bump script and workflow
- chore: remove non-existent azure directories from dependabot.yml
- chore: configure dependabot for terraform package-ecosystem
- chore: end-of-day governance sync — 2026-06-13
- chore: bump infra-core module refs to v2.7.0
- chore: dual-tool parity — add Claude Code bootstrap blocks to engage/02-dry-run/03-monitor-stress + CLAUDE.md exclusions
- chore: point reusable-terraform to dev branch for testing
- refactor: remove Cloudflare sanitization from provision workflow
- refactor: remove Cloudflare logic from shared engine
- docs: add NotebookLM educational prompts (infographic + short/long podcast) — 2026-06-03
- chore: clean up transient sync scripts
- chore: end-of-day governance sync — 2026-06-02
- chore: end-of-session governance sync — 2026-06-02
- chore: end-of-day governance sync — 2026-06-02
- chore: end-of-day governance sync — 2026-05-31
- chore: resolve split-brain — bump GHA self-refs v2.1.74→v2.2.2, Terraform pins →v2.6.9
- chore: update CHANGELOG for v2.2.2

### Fixed

- fix: pass Cloudflare secrets to pre-apply script

## v2.6.0 (2026-06-14)

### Added

- feat: configure bump-terraform-modules script and workflow to use GH_PAT for authentication
- feat: add automated bump-terraform-modules script and workflow

### Changed

- chore: end-of-day governance sync — 2026-06-14
- chore: end-of-day governance sync — 2026-06-14
- chore: bump GCP stack infra-core module refs to v2.7.1
- chore: bump infra-core module refs to v2.7.1
- chore: end-of-day governance sync - update CHANGELOG for bump script and workflow
- chore: remove non-existent azure directories from dependabot.yml
- chore: configure dependabot for terraform package-ecosystem
- chore: end-of-day governance sync — 2026-06-13
- chore: bump infra-core module refs to v2.7.0
- chore: dual-tool parity — add Claude Code bootstrap blocks to engage/02-dry-run/03-monitor-stress + CLAUDE.md exclusions
- chore: point reusable-terraform to dev branch for testing
- refactor: remove Cloudflare sanitization from provision workflow
- refactor: remove Cloudflare logic from shared engine
- docs: add NotebookLM educational prompts (infographic + short/long podcast) — 2026-06-03
- chore: clean up transient sync scripts
- chore: end-of-day governance sync — 2026-06-02
- chore: end-of-session governance sync — 2026-06-02
- chore: end-of-day governance sync — 2026-06-02
- chore: end-of-day governance sync — 2026-05-31
- chore: resolve split-brain — bump GHA self-refs v2.1.74→v2.2.2, Terraform pins →v2.6.9
- chore: update CHANGELOG for v2.2.2

### Fixed

- fix: pass Cloudflare secrets to pre-apply script

- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
<!-- ───────────── Plans 161–164 — CI/CD Hardening Sweep — 2026-06-14 ───────────── -->

### Security
- **security(supply-chain)** (Plan 162): SHA-pinned all third-party GitHub Actions — 176 floating `@vN` refs across 48 workflows + 9 composite actions converted to 40-char commit SHAs (79 → 255 pinned; 0 floating third-party refs remain). Fixed `azure/login` (was floating `@v2` with an unresolvable-SHA note). Added least-privilege `permissions:` blocks to 13 reusable workflows and fail-loud input validation to `docker-promote` / `check-access` (fail-closed) / `check-stack-exists`.
- **security(secrets)** (Plan 164): `sync-secrets-from-ssm.yml` now fails loud on missing required Mongo/Elastic SSM params (replaced silent `|| echo ""`) and masks all sensitive fields (usernames/host/endpoint, not just passwords). Scoped `id-token`/`pull-requests` to the jobs that need them in `10_security_scan.yml` (workflow default → `contents: read`). Removed the hardcoded AWS account id from `find-zombie.yml` (→ `secrets.AWS_ROLE_ARN`). Marked `setup-blaze` static AWS-key inputs deprecated (OIDC is the supported path).
- **security(ci-gate)** (Plan 164): Security-scan gate policy = block on infra/CI CRITICAL+HIGH — Trivy IaC blocks (exit-code 1) and a new SAST gate fails on high/critical Semgrep findings; app-dependency vulns remain advisory.

### Changed
- **refactor(network)** (Plan 165): Network topology routing upgraded to multi-site backbone. Removed duplicated legacy network stacks.
- **fix(cicd)** (Plan 161): ECS deploy pipeline hardening — stopped publishing mutable `:latest`/`:latest-amd64`/`:latest-arm64` image tags (only the immutable git-SHA tag is pushed); STAGE/PROD now always wait for ECS service stability (`skip_stability_wait` cannot disable the health gate there); hardened the task-def render (fail on empty output / invalid JSON / zero `containerDefinitions`); wired the previously-ignored `override_image_tag` (used only when `build_images=false` and a real non-`latest` tag, else `github.sha`).
- **fix(ops)** (Plan 163): De-risked destructive ops — dated S3/GCS state backups before `rm-state`/`wipe-state` (abort on backup failure); target-scoped confirmation keyword (`DESTROY-<env>-<stack>` / `DESTROY-<env>-<cloud>`) on manual dispatch of `99-ops-terraform`, `99-ops-nuke`, and `99-ops-utility` (programmatic `workflow_call` keeps the legacy keyword); `force-unlock` requires a `reason` and writes a durable audit record; `delete_asg.py`/`nuke_asg_lt.py` parameterised and refuse to delete unless `Blaze:Project`+`Blaze:Environment` tags match (fail closed). GCP Cloud Run nuke fails closed on an under-qualified prefix; full GCP/Azure label-based selection deferred pending confirmation of the label keys.

### Added
- **feat(dns)** (Plan 166): Added third-party DNS handoff verification lifecycle. `reusable-dns-handoff.yml` parses Terraform JSON outputs to dynamically generate a client handoff issue and status document. `reusable-dns-verify.yml` runs via cron, queries `1.1.1.1` to confirm CNAME propagation, auto-applies ACM certification, and closes the GitHub issue when complete.
- **feat(workflows)**: Propagated `smoke_test_url` input parameter to `02-deploy-app.yml` and all cloud-specific deployment wrappers (`02-deploy-aws.yml`, `02-deploy-azure.yml`, `02-deploy-gcp.yml`) to trigger post-deployment health verification.
- **feat(cicd)**: Added JSON schema validation for environment configurations (`vars/**/blaze-env.json`) using `ajv-cli` in `05_ci_no_cloud.yml`.
- **feat(workflows)**: Integrated Trivy IaC configuration scanning into CI (`terraform-tests.yml`) and security (`10_security_scan.yml`) workflows.
- **feat(cicd)**: Added automated bump-terraform-modules Python script and workflow to query and update module references.
- **feat(dependabot)**: Configured Dependabot git registries and `DEPENDABOT_PAT` secrets for private repository scanning.
- **chore(infra)**: Bumped `blaze-terraform-infra-core` module references to `v2.7.1` across all AWS and GCP live stack configurations.

### Changed
- **fix(elastic)** (Plan 160): Removed dead `elastic_app_username/password` outputs from the Elastic Cloud live wrapper stack (F1).
- **fix(secrets)** (Plan 160): Dropped empty-secret `ELASTIC_APP_*` syncing from `sync-secrets-from-ssm.yml` (F2).
- **chore(infra)**: Bumped `blaze-terraform-infra-core` module references to `v2.7.0`. (Old v2.7.0 bump)

### Security
- **security(ci)**: Secured Git credentials in the module bumper script using base64 basic Authorization headers, preventing token exposure in command arguments and execution logs.

<!-- ───────────── Plan 158 — Phase 1 (Stop the Bleeding) — 2026-06-11 ───────────── -->

### Security
- **security(azure-oidc)** (Plan 158 §1.2): Removed the `azure_*_rev` base64/`| rev` credential-obfuscation pattern from **14 workflows** (`01-provision-infra`, `02-deploy-{app,aws,azure,gcp,pages}`, `reusable-container-app-deploy`, `reusable-docker-build`, `reusable-stress-test-{deploy,provision,teardown,verify}`, `reusable-terraform-operations`, `reusable-terraform`). Deleted 19 `*_rev` input declarations, 87 passthrough lines and 49 `rev` decode lines; `azure/login@v2` now resolves identity directly from `secrets.AZURE_CLIENT_ID/TENANT_ID/SUBSCRIPTION_ID` (native OIDC federation). Behaviour-preserving — the `_rev` path was dead code (no caller set it), so the obfuscation added risk without function.

### Added
- **feat(ci)** (Plan 158 §1.3): `pin-guard` job in `05_ci_no_cloud.yml` — fails the build on any active `uses: …@dev` reference in `.github/workflows` or `.github/actions`, preventing floating dev pins from reaching `main`.

### Changed
- **fix(ci)** (Plan 158 §1.3): Repointed the `provision` job's `reusable-terraform.yml@dev` self-reference in `01-provision-infra.yml` to the released tag `@v2.2.2`, matching the 97 other internal pins. Zero active `@dev` references remain.
- **docs** (Plan 158 §1.3): README version badge corrected `v2.3.7` (non-existent tag) → `v2.2.2` (the in-use released tag).
- **refactor(azure)** (Plan 158 §1.2): Renamed the now-secret-only "Decode Azure Credentials" steps to "Set Azure Credentials (OIDC)" across 7 workflows; rewrote 18 `secrets.AZURE_* || steps.*.outputs.*` fallbacks to plain `secrets.AZURE_*`.
- **chore(ai)**: Removed legacy `docs/prompts` and completed migration to Antigravity 2.0 standards across `.agents/workflows`, `.github/agents`, and governance documents.
- **fix(infra)**: Implemented ECS scale-to-zero in `reusable-pre-destroy-cleanup.yml` to prevent `ResourceInUseException` during environment teardown.
- **refactor(ci)**: Stripped explicit `secrets:` from all `99-ops-*.yml` wrapper workflows to natively leverage the `secrets: inherit` standard.
- **fix(cicd)**: Deep CI/CD maintenance sync: regenerated `WORKFLOW_CATALOG.md` inputs, aligned reusable workflow references in AI agent markdown files, and bumped markdown timestamps globally.
- **fix(deps)**: Pinned GitHub Actions to latest (`v6.0.3`, `v7.0.1`) and Terraform modules to `v2.6.9` to resolve split-brain execution drift across environments.
- **fix(seed)**: Preserved Stage admin passwords during PROD-to-STAGE automated database imports to prevent leaked prod credentials.

## v2.2.2 (2026-05-30)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.2.1

### Fixed


## v2.2.2 (2026-05-30)

### Fixed

- `01-provision-infra.yml`: bump internal `reusable-terraform.yml` pin `v2.1.96` → `v2.2.1`. Root cause of `01c` multi-site-app apply failures: `v2.1.96` always-injects a CF placeholder token for ALL stacks (no conditional check), and does NOT export `CLOUDFLARE_API_TOKEN` to `$GITHUB_ENV`. The `multi-site-app/main.tf` CF provider was migrated in `v2.2.1` commit to read auth from `CLOUDFLARE_API_TOKEN` env var — with `v2.1.96` in the chain, `CLOUDFLARE_API_TOKEN` is never set by the workflow, so CF API calls during apply hit 400/9106 "Missing Authorization headers". Fix: pin to `v2.2.1` which has conditional placeholder logic (only injects placeholder when `enable_cloudflare_records=false`) and correctly exports `CLOUDFLARE_API_TOKEN`.

## v2.2.1 (2026-05-30)


### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.2.0

### Fixed


## v2.2.0 (2026-05-30)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.99

### Fixed


## v2.1.99 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.98

### Fixed


## v2.1.98 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.97
- chore: update CHANGELOG for v2.1.96

### Fixed


## v2.1.97 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.96

### Fixed


## v2.1.96 (2026-05-29)

### Added

- No new features in this release

### Changed


### Fixed


## v2.1.95 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.94

### Fixed


## v2.1.94 (2026-05-29)

### Added

- No new features in this release

### Changed


### Fixed


## v2.1.93 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.92

### Fixed


## v2.1.92 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.90

### Fixed


## v2.1.90 (2026-05-29)

### Added

- No new features in this release

### Changed

- chore: update CHANGELOG for v2.1.89 — add CF token fix note
- chore: update CHANGELOG for v2.1.89
- chore: update CHANGELOG for v2.1.89

### Fixed


## v2.1.89 (2026-05-29)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.88

### Fixed


## v2.1.88 (2026-05-28)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.87
- chore: update CHANGELOG for v2.1.87

### Fixed


## v2.1.87 (2026-05-28)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.87

### Fixed


## v2.1.87 (2026-05-28)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed


### Fixed


## v2.1.86 (2026-05-28)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-05-28
- docs: daily audit update 2026-05-28
- chore: end-of-day governance sync — 2026-05-27
- chore: end-of-day governance sync — 2026-05-26
- chore: Google Antigravity 2.0 migration + end-of-day governance sync — 2026-05-26
- chore: align engage workflow and update print_env_versions paths
- chore: end-of-day governance sync — 2026-05-15
- chore: update CHANGELOG for v2.1.85
- chore: update CHANGELOG for v2.1.85
- chore: update CHANGELOG for v2.1.84

### Fixed

- fix(checkengines): scope TF ref scan to deploy .github/ only (Engine 4)
- fix: bump dev-mini-network module refs v2.6.4 → v2.6.5 (resolve split-brain)

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Added
- **feat(ai)**: `AGENTS.md` (repo root) — plain-markdown project context for all AI tools (Copilot, Cursor, Antigravity, Aider).
- **feat(ai)**: `.github/agents/maintainer.agent.md` — VS Code Custom Agent persona for the `@maintainer` role.
- **feat(ai)**: `.github/agents/sre.agent.md` — VS Code Custom Agent persona for the `@sre` role.

### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).
- **docs(catalog)**: `WORKFLOW_CATALOG.md` corrected workflow count (38+24=62 was wrong → 30+24=54 actual files); bumped to v2.2.3.
- **docs(catalog)**: `REUSABLE_WORKFLOWS.md` fixed stale `stress-test.yml` code example (file no longer exists); version pins updated to v2.2.2; timestamps updated to 2026-06-02.
- **docs(workflows)**: `troubleshoot-terraform-locks.md` — replaced hardcoded `thisisblaze` state key examples with generic `<project-key>/<client>` placeholders; timestamp updated to 2026-06-02.
- **docs(workflows)**: `debug-cicd-workflows.md` — timestamp updated to 2026-06-02 (content verified accurate).
- **docs(workflows)**: `03-monitor-stress.md` — fixed stale `--workflow=stress-test.yml` reference (file does not exist; now points to `03-stress-test.yml` wrapper in tenant repo).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Changed
- **chore(ai)**: Platform-Agnostic Workflow Optimization (Plan 154 Phase 1-5). Upgraded all agent workflows across the 4 repositories to gracefully degrade between Antigravity 2.0 (native tools) and CLI agents (Claude Code).
- **chore(ai)**: IDE Parity. Synced `.cursorrules` Agent Workflows instructions and instantiated `.github/copilot-instructions.md` to ensure identical `/slash-command` execution behavior across Cursor and GitHub Copilot.
### Fixed
- **fix(checkengines/Engine 4)**: `engine4_modules.py` — Added FREEZE-annotation filter: lines containing `# FREEZE` are skipped when scanning blaze-actions workflow refs, preventing the intentional `v2.1.74` chaos-test pin in `90-daily-health-check.yml` from triggering false split-brain detection.
- **fix(checkengines/Engine 4)**: `engine4_modules.py` — Scoped Terraform ref scan to `deploy_path/.github/` only. Previously the engine scanned `_shared/blaze-actions/` workspace mirror (a separate directory with an older checkout), producing false-positive split-brain on `v2.6.4`/`v2.6.5` refs. blaze-actions contains no Terraform live stacks.
- **fix(checkengines/Engine 8)**: `engine8_workflows.py` — Added `INTENTIONAL_DIVERGENCE` allowlist. `90-daily-health-check.yml` differs between repos by design: `blaze-template-deploy` extends it with the `mcp-healing-agent` job (blaze-conductor + `ANTHROPIC_API_KEY`) which must never exist in the public blaze-actions repo per ADR-017.

### Changed
- **chore(agent/governance)**: `engage.md` — Updated to 4-repo architecture. Repo map now includes `blaze-conductor` (private, `thisisblaze`). `blaze-actions` flagged as **PUBLIC** in map. Pull step covers all 4 repos. Ready Report includes conductor status line.
- **chore(agent/governance)**: `allstop.md` — "3 repos" → "4 repos" throughout.
- **chore(agent/governance)**: `checkengines.md` — "3 repos" → "4 repos" throughout.
- **chore(agent/governance)**: `13-deep-cicd-maintenance.md` — Scope expanded to 4 repos. `blaze-conductor` added to Repositories in Scope. CAUTION block added: `blaze-actions` is **PUBLIC** — no conductor/MCP references allowed. Phase 2 agent scan, Phase 4 git log updated. Date bumped to 2026-05-27.

---

## [v2.1.86] - 2026-05-26

### Changed

- **docs**: Added Cloudflare provider validation failure troubleshooting (dummy token requirement `abcdefghijklmnopqrstuvwxyz0123456789ABCD` for disconnected applies) to `cloudflare-operations.md`.
- **chore(ai)**: Migrated to Google Antigravity 2.0 (Environment Agnostic) standard — `.antigravity/` consolidated into `.agents/`, `.antigravityignore` renamed to `.agentignore`, hardcoded IDE paths eradicated, `AI_CONTEXT_GOVERNANCE.md` upgraded.
- **chore(ai)**: Purged all 21 hardcoded `/Users/marek/` absolute paths from utility scripts and agent workflows — now use relative resolution and `SCRIPT_DIR`.
- **fix(infra)**: Bumped `dev-mini-network/main.tf` module ref `v2.6.4` → `v2.6.5` to resolve split-brain with `blaze-template-deploy`.

## [v2.1.85] - 2026-05-15

### Fixed

- **[P2] Cloudflare DNS catch-all `state rm` on destroy** (`reusable-terraform.yml`): The existing purge step only covered `module.environment_network.cloudflare_dns_record.*` (network stack pattern). Added a catch-all dynamic sweep that removes every `cloudflare_dns_record.*` address from state regardless of module path or map key — covering the multi-site-app pattern `cloudflare_dns_record.site["thisisblaze-frontend"]` that caused the 2026-05-15 stage nuke failure.
- **[P2] Data stack warning at safety gate** (`99-nuke-env.yml`): MongoDB Atlas and Elastic Cloud warning is now printed at workflow start inside the Safety Gate step, not buried in the job summary at the end.
- **[P3] VPC force-delete fallback in verify-destroy-complete** (`99-nuke-env.yml`): After all Terraform destroy jobs, scans for any VPCs tagged `Blaze:Environment` that survived the nuke and force-deletes them (IGWs, subnets, SGs, VPC). Runs with `continue-on-error: true`. Covers crash-interrupted nuke scenarios like the 2026-05-15 laptop crash event.


## v2.1.84 (2026-05-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.84
- chore: update CHANGELOG for v2.1.83
- chore: end-of-day governance sync — 2026-05-14
- chore: update CHANGELOG for v2.1.82

### Fixed


## [v2.1.84] - 2026-05-15

### Fixed

- **[P1] IGW DependencyViolation on VPC destroy** (`reusable-terraform.yml`): After removing the Internet Gateway from Terraform state (`state rm`), now also CLI-detaches and deletes the physical AWS IGW via `aws ec2 detach-internet-gateway` + `delete-internet-gateway`. Previously the physical IGW remained attached, causing `DependencyViolation` when Terraform attempted to delete the VPC. Root cause: 2026-05-15 nuke failure on `vpc-0d27e5f9065a0b113` (10.2.0.0/16).
- **[P1] Atlas `GROUP_NOT_FOUND` state guard** (`mongodb/pre-destroy.sh`): Added a pre-flight project existence check before any Atlas API calls. If the Atlas project returns 404/GROUP_NOT_FOUND (reprovisioned externally or deleted out-of-band), all `mongodbatlas_*` and `cloudflare_dns_record` resources are purged from state so `terraform destroy` exits cleanly instead of failing. Root cause: 2026-05-15 stage nuke failed on orphaned project `6a065298a1c2b19656835825`.


## v2.1.83 (2026-05-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-05-14
- chore: update CHANGELOG for v2.1.82

### Fixed


## v2.1.82-ops (2026-05-15)

### Operations
- ops(stage/2026-05-15): `01c - Provision App Infra` stage/thisisblaze ✅ `Apply complete! Resources: 3 added, 22 changed, 0 destroyed.` (run #25893833780). Full stack provisioned via 5-layer import script fix chain.
- ops(stage/2026-05-15): `import-existing-resources.sh` — enabled root-scope CF DNS imports (Step 4.5), added `get_cf_module_for_domain()` for correct `site_cdn`/`admin_cdn`/`assets_cdn` routing (Step 4.4), stale CF CNAME cleanup.
- ops(stage/2026-05-15): `stage-multi-site-app/pre_apply.sh` — removed dead Section 5 CF DNS block (domain-resolution bug + `set -u` crash on undefined vars).

## v2.1.82 (2026-05-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.82
- chore: update CHANGELOG for v2.1.82
- chore: update CHANGELOG for v2.1.82
- chore: update CHANGELOG for v2.1.81

### Fixed


## v2.1.82 (2026-05-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.82
- chore: update CHANGELOG for v2.1.82
- chore: update CHANGELOG for v2.1.81

### Fixed


## v2.1.82 (2026-05-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.82
- chore: update CHANGELOG for v2.1.81

### Fixed


## v2.1.82 (2026-05-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.81

### Fixed


## v2.1.81 (2026-05-14)

### Added

- feat: complete Plan 155 StackID hardening in pre-destroy cleanup and ops-nuke

### Changed

- chore: update CHANGELOG for v2.1.81
- chore: prepare v2.1.81 release
- chore: end-of-day governance sync — 2026-05-14
- chore: end-of-day governance sync — 2026-05-14
- chore: bump all infra-core refs v2.6.2 → v2.6.3 (Plan 151 security release)
- chore: end-of-day governance sync — 2026-05-13
- docs: update CHANGELOG + WORKFLOW_CATALOG for /12-best-practice-audit
- chore: end-of-day governance sync — 2026-05-12
- chore: end-of-day governance sync — 2026-05-10
- chore: end-of-day governance sync — 2026-05-10
- chore: end-of-day governance sync 2026-05-10 — date bump
- chore: end-of-day governance sync — 2026-05-09
- chore: /13-deep-cicd-maintenance — Engine 4 v2.4.8→v2.5.12, Engine 8 parity, Blaze:StackID docs — 2026-05-09
- chore: end-of-day governance sync — 2026-05-09
- chore: end-of-day governance sync — 2026-05-09
- chore: end-of-day governance sync — 2026-05-09 (allstop) + reusable-dev-sleep-schedule.yml Plan 151 L4
- chore: update CHANGELOG for v2.1.80
- chore: update CHANGELOG for v2.1.79
- chore: update CHANGELOG for v2.1.78

### Fixed


## v2.1.81 (2026-05-14)

### Added

- feat: complete Plan 155 StackID hardening in pre-destroy cleanup and ops-nuke

### Changed

- chore: prepare v2.1.81 release
- chore: end-of-day governance sync — 2026-05-14
- chore: end-of-day governance sync — 2026-05-14
- chore: bump all infra-core refs v2.6.2 → v2.6.3 (Plan 151 security release)
- chore: end-of-day governance sync — 2026-05-13
- docs: update CHANGELOG + WORKFLOW_CATALOG for /12-best-practice-audit
- chore: end-of-day governance sync — 2026-05-12
- chore: end-of-day governance sync — 2026-05-10
- chore: end-of-day governance sync — 2026-05-10
- chore: end-of-day governance sync 2026-05-10 — date bump
- chore: end-of-day governance sync — 2026-05-09
- chore: /13-deep-cicd-maintenance — Engine 4 v2.4.8→v2.5.12, Engine 8 parity, Blaze:StackID docs — 2026-05-09
- chore: end-of-day governance sync — 2026-05-09
- chore: end-of-day governance sync — 2026-05-09
- chore: end-of-day governance sync — 2026-05-09 (allstop) + reusable-dev-sleep-schedule.yml Plan 151 L4
- chore: update CHANGELOG for v2.1.80
- chore: update CHANGELOG for v2.1.79
- chore: update CHANGELOG for v2.1.78

### Fixed


## [v2.1.81] — 2026-05-14 (Plan 158)

### Infrastructure
- **GCP live stacks**: All `blaze-actions/.github/gcp/infra/live/**` Terraform module refs bumped `v2.6.2 → v2.6.3` (`dev-network`, `dev-data`, `multi-site-app`). Picks up `blaze-terraform-infra-core` v2.6.3 security release (S3 versioning default fix, RDS backup defaults, `prevent_destroy` on stateful services).

### Added (Plan 158 — L25: Blaze:StackID Tag Propagation)
- **`reusable-terraform.yml`**: New optional `stack_id` workflow_call input. Injected as `TF_VAR_stack_id` in the "Inject Blaze Signature Tag Vars" step — propagates `STACK_ID` UUID from `blaze-env.json` into the Terraform environment. Logged as `🏷️ Blaze:StackID` for visibility in run logs.
- **`01-provision-infra.yml`**: `stack_id` threaded from `calculate-config` outputs → `configuration` job outputs → `provision` job `with:` block → `reusable-terraform.yml` input. No new secrets or manual config required.

### Fixed
- **`99-ops-nuke.yml`**: bumped `check-access` action pin to `v2.1.80`, fixed broken `uses:` in `02-deploy-pages`, added `timeout-minutes: 35`.
- **`02-deploy-app.yml`**: security hardening — resolved broken `uses:` reference.

### Governance
- chore: end-of-day governance sync — 2026-05-14. All 3 repos 14/14 ✅.



### Agent Tooling
- **`docs/learning/REFERENCE_SOURCE_LIBRARY.md`** — New curated 5-domain reference source library. Domains: GH Actions reusable workflow patterns, AWS OIDC, Terraform CI/CD, deployment patterns, access control. Cross-references all `docs/knowledge/*.md` smart fixes with 🔴/🟡/🟢 relevance tiers. 9 priority audit checks defined.
- **`.agents/workflows/12-best-practice-audit.md`** — New read-only monthly audit workflow. Checks OIDC role scoping, actionlint coverage, SHA pinning, concurrency groups, secret inheritance, timeout-minutes, check-access gating, and pre-destroy cleanup. Includes knowledge base freshness check. Produces `docs/reports/YYYY-MM-DD-best-practice-audit.md`.

### Governance
- chore: end-of-day governance sync — 2026-05-12. Governance files verified (14/14 ✅).

### Changed
- chore(modules/2026-05-12): bump all AWS live stack Terraform module refs `v2.5.12` → `v2.6.2` (19 files, 41 occurrences). All AWS live stacks now at full parity with `blaze-terraform-infra-core` latest tag. Eliminates split-brain drift.
- chore(modules/2026-05-10): bump all GCP live stack Terraform module refs `v2.5.12` → `v2.6.2` (31 files). GCP stacks now at full parity with AWS stacks on `v2.6.2`.
- chore: end-of-day governance sync — 2026-05-10

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.
 — 2026-05-09 — /13-deep-cicd-maintenance

### Changed
- chore(maintenance): bump all `blaze-template-deploy` Terraform module refs from `v2.4.8` → `v2.5.12` across all 58 live stacks (AWS + GCP). Eliminates Engine 4 split-brain drift detected by `/checkengines`.
- chore(parity): copy `90-daily-health-check.yml` byte-for-byte from `blaze-actions` to `blaze-template-deploy` and `blaze-terraform-infra-core`. Resolves Engine 8 structural parity failure.
- docs(stackid): propagate `Blaze:StackID` UUID tag architecture (Plan 155) into `README.md` (new §🆔 Environment Isolation section) and `docs/AI_CONTEXT_GOVERNANCE.md` (§1.6 Signature Tag Rule expanded).
- chore: clean up `scratch_fix_versions.py` temporary script.

## v2.1.80 (2026-05-09)

### Added

- **`WORKFLOW_CATALOG.md`**: 3 new reusable workflows documented — `reusable-backup-snapshot.yml` (Plan 151 L14 + Plan 152), `reusable-dev-sleep-schedule.yml` (Plan 151 L4 FinOps), `reusable-ecs-health-snapshot.yml` (Plan 151 L7 observability). Total: 38 main + 24 reusable = 62 workflows.

### Changed

- chore: end-of-day governance sync — 2026-05-09
- **Engine 8 parity fix**: `90-daily-health-check.yml` self-pins bumped `@v2.1.74→@v2.1.80` — SHA hash now identical across all 3 repos.
- **WORKFLOW_CATALOG.md**: Header version `v2.1.77→v2.1.80`, count `59→62`, Last Updated `2026-05-08→2026-05-09`.
- **All GitHub Actions tags**: `@v2.1.74→@v2.1.80` sweep complete across blaze-template-deploy (54+ workflows) and blaze-terraform-infra-core.


## v2.1.79 (2026-05-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.78

### Fixed


## v2.1.78 (2026-05-09)

### Added

- feat: publish deployed Elastic Beanstalk version to SSM Parameter Store

### Changed

- docs: add prod safety boundary to orphan rule
- chore: end-of-day governance sync — 2026-05-08
- chore: end-of-day governance sync — 2026-05-07
- chore: update CHANGELOG for v2.1.77
- chore: end-of-day governance sync — 2026-05-06
- chore: end-of-day governance sync — 2026-05-05
- chore: end-of-day governance sync — 2026-05-02
- docs: sync timestamps for deep cicd maintenance
- docs: bump workflow catalog versions to v2.5.7 for deep cicd maintenance sync
- chore: update CHANGELOG for v2.5.7
- chore: end-of-day governance sync — 2026-05-02
- chore: end-of-day governance sync — 2026-05-01
- chore: update CHANGELOG for v2.1.76

### Fixed

- fix: pre-destroy cleanup should check both standard and Blaze tag schemas

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.


>>>>>>> dev
## [v2.1.80] — 2026-05-09 (Plan 152 Phase 4)

### Added

- feat(backup): `reusable-backup-snapshot.yml` — new Job 4: `docdb-snapshot` (Plan 152 Phase 4).
  - New optional input: `docdb_cluster_identifier` (default `""` — skips job when empty, fully backwards-compatible).
  - **Idempotent**: checks for existing snapshot with today's date (`${cluster-id}-backup-YYYY-MM-DD`) before creating — safe to re-run.
  - **Cluster state guard**: skips snapshot if cluster is not in `available` state (e.g. backup window conflict, maintenance).
  - **Polled wait**: custom `sleep 30` poll loop (DocDB has no native `wait` CLI command) — times out gracefully at 25 minutes without failing the workflow (snapshot creation already initiated).
  - Tagged with `Blaze:BackupType=scheduled`, `Blaze:BackupDate=YYYY-MM-DD`, `ManagedBy=github-actions` — consistent with RDS snapshot tagging.

## [v2.1.79] — 2026-05-09 (Plan 152 Phase 3)

### Added

- feat(pre-destroy): `reusable-pre-destroy-cleanup.yml` — `Disable DocumentDB Deletion Protection` step (Plan 152 Phase 3).
  - Discovers DocumentDB clusters via tag-based lookup (`Blaze:Project` + `Blaze:Environment`) — no hardcoded name patterns.
  - Verifies engine is `docdb` before acting (skips Aurora/RDS clusters that share tags safely).
  - Disables `deletion_protection` before `terraform destroy` runs — required because Terraform cannot modify deletion protection on a cluster being destroyed in the same plan.
  - Full `dry_run` support — shows what would be modified without touching live infrastructure.
  - Safe no-op when no DocumentDB cluster exists for the project/environment.

## [v2.1.78] — 2026-05-09 (Plan 151)

### Added

- feat(backup): `reusable-backup-snapshot.yml` — new 3-job reusable backup workflow: RDS snapshot creation, SSM parameter inventory export to S3, and S3 versioning integrity assertions (Plan 151 L14).

### Fixed

- fix(pre-destroy): `reusable-pre-destroy-cleanup.yml` — added `Cleanup S3 CRR Configs` step that runs `delete-bucket-replication` BEFORE `object_versions.delete()`. Prevents destroy failures on stacks with S3 Cross-Region Replication enabled (Plan 151 L5/L13 prerequisite).

### Fixed

- fix(ci): `reusable-stress-test-teardown.yml:968` — added `destroy-app` to `destroy-network` `needs:` list. It was referenced in the job's `if:` condition but was not in the `needs:` chain, causing an `actionlint [expression]` error.
- fix(ci): `reusable-terraform.yml` — declared missing `orphan_lambda_namespace` input (`type: string, default: "blaze"`). Was used in Orphan Lambda step but never declared in `workflow_call` inputs.

### Changed

- fix(ci): `05_ci_no_cloud.yml` — actionlint now scans all 54 workflow files (was 3 hardcoded). Shellcheck integration disabled (`-shellcheck ''`) to reduce noise. `|| true` removed — linter now exits 1 on any GHA expression error, blocking PRs.
- chore: `.cursorrules` §7.1 — added workflow validation checklist covering actionlint requirements and anti-pattern documentation.
- chore: `.gitignore` — added `actionlint` binary.

## v2.1.77 (2026-05-08)

### Changed

- docs: Deep CI/CD Maintenance — WORKFLOW_CATALOG.md: added `php_version`+`build_command` inputs to `02-deploy-aws.yml`, moved misplaced EB table row into Reusable section with full input docs, fixed total count to 59, bumped version header to v2.1.77
- docs: REUSABLE_WORKFLOWS.md: added `reusable-elastic-beanstalk-deploy.yml` calling pattern section with full YAML example and input reference, updated stable version pin references to v2.1.77
- chore: bump both docs timestamps to 2026-05-08

## v2.1.77 (2026-05-06)

### Added

- feat: publish deployed Elastic Beanstalk version to SSM Parameter Store

### Changed

- chore: end-of-day governance sync — 2026-05-06
- chore: end-of-day governance sync — 2026-05-05
- chore: end-of-day governance sync — 2026-05-02
- docs: sync timestamps for deep cicd maintenance
- docs: bump workflow catalog versions to v2.5.7 for deep cicd maintenance sync
- chore: update CHANGELOG for v2.5.7
- chore: end-of-day governance sync — 2026-05-02
- chore: end-of-day governance sync — 2026-05-01
- chore: update CHANGELOG for v2.1.76

### Fixed

- fix: pre-destroy cleanup should check both standard and Blaze tag schemas

## v2.5.7 (2026-05-02)

### Added

- feat: publish deployed Elastic Beanstalk version to SSM Parameter Store

### Changed

- chore: end-of-day governance sync — 2026-05-02
- chore: end-of-day governance sync — 2026-05-01
- chore: update CHANGELOG for v2.1.76

### Fixed

- fix: pre-destroy cleanup should check both standard and Blaze tag schemas

## [2026-05-06] — Deep CI/CD Maintenance & Module Version Sync

### Changed
- chore(maintenance): bump all AWS + GCP live stack Terraform module refs to `v2.5.10` (from `v2.4.8`/`v2.5.9`). Eliminates Engine 4 split-brain drift across all environments.
- chore(maintenance): bump all internal `blaze-actions` action + workflow pin refs from `@v2.1.74`/`@dev` to `@v2.1.76` (canonical stable).
- chore: end-of-day governance sync — 2026-05-06

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.

### Added

- docs(knowledge): added guide on how to implement `ALLOWED_INFRA_USERS` access control for external repositories.

## v2.1.76 (2026-05-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.75

### Fixed

- fix: resolve multiline bash parsing bug in build_command

## v2.1.76 (2026-05-01)

### Fixed

- fix: resolved a critical bash parsing bug in `reusable-elastic-beanstalk-deploy.yml` where multiline `build_command` inputs were incorrectly evaluated by `[ -n ]`, causing silent deployment failures. Multiline commands are now securely executed via a temporary script dump.

## v2.1.75 (2026-05-01)

### Added

- feat: add build_command input to eb deploy workflow

### Changed

- chore: end-of-day governance sync — 2026-04-30
- chore: end-of-day governance sync — 2026-04-30
- chore: update CHANGELOG for v2.1.74

### Fixed

- fix: bump actions/checkout to v6.0.2 to resolve Node.js 20 deprecation
- fix: pass MONGODB_ATLAS_PROJECT_ID to ensure we reuse a single MongoDB Atlas project
- fix: pass missing third-party secrets to teardown and provision steps

## v2.1.74 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.74
- chore: update CHANGELOG for v2.1.74
- chore: update CHANGELOG for v2.1.74
- docs: update CHANGELOG for v2.1.74 / v2.4.8 deep ci/cd sync
- chore: update CHANGELOG for v2.1.73

### Fixed

- fix: Force stop ECS tasks to prevent ECS service Draining collisions during Provision
- fix: Robust empty JSON parsing for terraform_vars
- fix: revert bad v2.1.73 global find-and-replace to dev

## v2.1.74 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.74
- chore: update CHANGELOG for v2.1.74
- docs: update CHANGELOG for v2.1.74 / v2.4.8 deep ci/cd sync
- chore: update CHANGELOG for v2.1.73

### Fixed

- fix: Robust empty JSON parsing for terraform_vars
- fix: revert bad v2.1.73 global find-and-replace to dev

## v2.1.74 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.74
- docs: update CHANGELOG for v2.1.74 / v2.4.8 deep ci/cd sync
- chore: update CHANGELOG for v2.1.73

### Fixed

- fix: revert bad v2.1.73 global find-and-replace to dev

## v2.1.74 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- docs: update CHANGELOG for v2.1.74 / v2.4.8 deep ci/cd sync
- chore: update CHANGELOG for v2.1.73

### Fixed

- fix: revert bad v2.1.73 global find-and-replace to dev

## v2.1.73 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: globally bump internal workflow references to v2.1.73 to ensure jq strict null fix is executed
- chore: update CHANGELOG for v2.1.72

### Fixed


## v2.1.72 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.71

### Fixed


## v2.1.71 (2026-04-24)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: add find zombie workflow
- chore: update CHANGELOG for v2.1.70

### Fixed

- fix: restrict pre-destroy cleanup to appropriate target_stacks
- fix: add push trigger to run find-zombie

## v2.1.70 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump internal reusable workflow references to v2.1.70
- chore: update CHANGELOG for v2.1.70
- chore: update CHANGELOG for v2.1.69

### Fixed


## v2.1.70 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.69

### Fixed


## v2.1.69 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump action versions to v2.1.69
- chore: update CHANGELOG for v2.1.69
- chore: update CHANGELOG.md for bash syntax error fix
- chore: update CHANGELOG for v2.1.68
- chore: update CHANGELOG for v2.1.68
- chore: update CHANGELOG for v2.1.67

### Fixed


## v2.1.69 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG.md for bash syntax error fix
- chore: update CHANGELOG for v2.1.68
- chore: update CHANGELOG for v2.1.68
- chore: update CHANGELOG for v2.1.67

### Fixed


## v2.1.68 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.68
- chore: update CHANGELOG for v2.1.67

### Fixed


## v2.1.68 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.67

### Fixed


## v2.1.68 (2026-04-23)

- fix(ci): bump all internal nested workflow references to `v2.1.68` (from `v2.1.62`/`v2.1.66`) to ensure updated teardown and GC logic is actually executed during stress tests.
- fix(infra): resolve orphaned `else` and `fi` blocks causing bash syntax errors in the `01-provision-infra.yml` pre-apply logic, preventing successful multi-tenant infrastructure provisioning.

## v2.1.67 (2026-04-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: prepare v2.1.67 release
- chore: end-of-day governance sync — 2026-04-23
- chore: end-of-day governance sync — 2026-04-23
- chore: end-of-day governance sync — 2026-04-22
- chore: bump modules to v2.4.6 to resolve split brain
- chore: update changelog for archived legacy scripts
- chore: archive legacy deploy and nuke scripts
- chore: end-of-day governance sync — 2026-04-21
- chore: end-of-day governance sync — 2026-04-21
- chore: bump infra-core version pin v2.3.7 → v2.4.0 in governance docs
- chore: end-of-day governance sync — 2026-04-20

### Fixed


## v2.1.67 (2026-04-23)

- fix(teardown): add tag-based Garbage Collection for ALB Target Groups and CloudFront distributions to prevent 409 ghost resource conflicts during environment reprovisioning.
- fix(teardown): expand Cloudflare DNS zombie cleanup target list to include `dev.thisisblaze.uk`, `admin-dev`, and other canonical routing patterns.
- chore: performed deep CI/CD maintenance sweep, aligning WORKFLOW_CATALOG.md, REUSABLE_WORKFLOWS.md, and all agent workflow timestamps to the 02-deploy-app.yml standard and v2.4.6 versions.
- chore: execute `/checkengines` sweep and resolve module split-brain, bumping Azure and GCP live modules natively to `v2.4.6`.
- fix: resolved Node.js 20 deprecation warning by upgrading `aws-actions/configure-aws-credentials` strictly pinned SHA from `v4.0.2` to `v6.1.0` across all workflows.
- fix: replaced outdated `04-deploy-multi-site` references in `.cursorrules` with `02-deploy-app` and `multi-site-app` standard.
- chore: end-of-day governance sync — 2026-04-22.
- chore: end-of-day governance sync — 2026-04-23.

## v2.1.66 (2026-04-20)

- fix: replace broken azure/login SHA across all workflow files (7247ffa)
## v2.1.65 (2026-04-20)

- Maintenance release
## v2.1.64 (2026-04-20)

- fix: resolve azure/login broken SHA pin in reusable-terraform (3a84dd1)
## v2.1.63 (2026-04-20)

- feat(security): pre-flight Cloudflare Zone ID domain validation (9e79046)
- chore: end-of-day governance sync — 2026-04-20 (8dbaf22)
- fix(01-provision-infra): default launch type EC2+ARM64 (was FARGATE) (0f88f8c)
- fix(plan-144): fix V2 tag schema drift in pre-destroy cleanup (Blaze:Project → blaze:project) (1c2f997)
- chore: /13-deep-cicd-maintenance sync — 2026-04-20 (fc7ce9f)
- chore: end-of-day governance sync — 2026-04-20 (e1e028b)
- chore(docs): Deep CI/CD Maintenance - Map Plan 144/146 additions into repository catalogs and changelogs (2558616)
- feat(workflow): Add workers_json parsing and routing for Plan 146 Dual Engine Setup (b92622f)
- feat(ci): Plan 144 Hardening - Case B outputs, strict resourcegroupstaggingapi ECS resolution, and precise nuke isolation scoping (8b16156)
- fix(ci): wire Semantic Hub db_ssm_path for DB user provisioning (bbb6d1b)
- chore: /13-deep-cicd-maintenance sweep (15a3c63)
- fix(security): enforcing strictly pinned SHAs matching v4/v3/v2 releases across action wrappers (157ec5a)
- fix(state): sandbox third-party-mongodb terraform state by STAGE_KEY to prevent env cross-contamination upon reprovisioning (723ea67)
- chore: end-of-day governance sync — 2026-04-18 (83a0a8c)
- chore: execute /13-deep-cicd-maintenance sync — bumped global workflow schema to v2.1.62 and enforced Tagging API teardown logic (942e972)
- fix(ops): explicitly force-delete ASG before Launch Template cleanup (282b580)
- chore: update CHANGELOG for v2.1.62 (dfe173b)
## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(ci): executed `/13-deep-cicd-maintenance` global synchronization suite.
- feat(ci): enforced complete structural workflow parity across `blaze-actions` and `blaze-template-deploy`, bumping tags to `@v2.1.74`.
- feat(ci): hardened teardown scripts with native `jq` type safety (`type=="array"`) to elegantly handle AWS CLI `null` capacityProviders during ECS cluster deletion.
- feat(infra): enforced strict `trimsuffix("-")` to prevent AWS validation errors when 32-character ALB project prefixes truncate at a hyphen.
- feat(ci): systematically bumped all nested internal workflow tags to `v2.1.74` and terraform core refs to `v2.4.8` to definitively seal the pipeline from referencing stale, buggy logic.


### Changed
- fix(import): updated `import.sh` to correctly import tenant-specific Cloudflare DNS records (`cloudflare_dns_record.api[0]`, etc.) for the `app` stack, resolving persistent `CNAMEAlreadyExists` crashes during zero-state or clean-slate provisioning.
- chore: archived legacy monolithic deployment scripts (`deploy-site.yml`, `deploy-azure-site.yml`, `deploy-gcp-site.yml`) and ad-hoc script `nuke-cloudfront.yml` to strictly enforce the modular Multi-Tenant V2 `reusable-*` and native nuke pipelines.

### Added
- feat(ops): synchronized Deep CI/CD maintenance globally mapping all live stacks natively from v2.3.7 array drift to centralized v2.4.3 templates
- feat(actions): corrected WORKFLOW_CATALOG mathematical counts mapping to exactly 53 workflows and cleared ghosted pipeline references sequentially

 - 2026-04-20

### Added
- feat(93d/93e): Tag test workflows updated for V2 lowercase schema and 3-project coverage.

### Changed
- fix(01-provision-infra): `api_launch_type` + `frontend_launch_type` defaults changed `FARGATE` → `EC2` in both `workflow_dispatch` and `workflow_call` sections. ARM64 is now the first option. Matches shared-ASG platform model.
- fix(reusable-pre-destroy-cleanup): ECS task definition tag filter corrected from legacy `Blaze:Environment` → V2 lowercase `blaze:stage` schema. Prevents resource ghosting on teardown.
- chore: end-of-day governance sync — 2026-04-20
- docs: propagated Plan 146 Dual-Engine Worker documentation parity from blaze-template-deploy
- docs: aligned AI_CONTEXT_GOVERNANCE.md version pins to v2.3.8 / v2.1.62 baseline


## v2.1.62 (2026-04-17)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.62
- chore: update CHANGELOG for v2.1.62
- chore: execute /13-deep-cicd-maintenance sync — validate v2.1.61 zero-state logic and timestamps
- chore: update CHANGELOG for v2.1.61
- chore: update CHANGELOG for v2.1.60

### Fixed


## v2.1.62 (2026-04-17)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.62
- chore: execute /13-deep-cicd-maintenance sync — validate v2.1.61 zero-state logic and timestamps
- chore: update CHANGELOG for v2.1.61
- chore: update CHANGELOG for v2.1.60

### Fixed


## v2.1.62 (2026-04-17)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: execute /13-deep-cicd-maintenance sync — validate v2.1.61 zero-state logic and timestamps
- chore: update CHANGELOG for v2.1.61
- chore: update CHANGELOG for v2.1.60

### Fixed


## v2.1.61 (2026-04-17)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.60

### Fixed

- **Garbage Collection (99-ops-aws)**: Handled missing Lambda@Edge bindings natively (`grep` short-circuit `|| true`) to ensure zero-state environments do not trigger false-positive exit codes during dry runs or teardowns.

## v2.1.60 (2026-04-17)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: execute /13-deep-cicd-maintenance sync
- chore: update CHANGELOG for v2.1.59

### Fixed


## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### Changed
- chore: execute `/13-deep-cicd-maintenance` sync — resolved Git blocker states, audited and synchronized WORKFLOW_CATALOG and REUSABLE_WORKFLOWS, updated Agent deployment triggers to target `01c-provision-app-infra.yml`, and aligned timestamps across repositories.


### Changed
- chore: execute `/13-deep-cicd-maintenance` sync — pinned internal workflow actions universally to `@v2.1.62`.
- feat(99-ops-aws): completely overhauled `cleanup-orphaned-lambdas` and other GC algorithms to exclusively use native Tag-Based discovery (`Blaze:Environment`) instead of name prefix arrays.

### Added
- **Smart Import Reconciliation**: Replaced destructive `terraform state rm` in `01-provision-infra` with `terraform import` for Lambda@Edge and WAF to prevent `ResourceConflictException` (HTTP 409) collisions.
- **Surgical Telemetry GC**: Overhauled `cleanup-orphaned-lambdas` logic. The GC now natively queries CloudFront `LambdaFunctionAssociations` to perfectly skip active functions instead of blindly relying on AWS deletion exceptions.
- **Robust DNS Nuke**: Re-enabled `nuke-cleanup-dns` to purge persistent Cloudflare stage aliases during teardowns.

### Changed
- chore: Bump versions and execute `/13-deep-cicd-maintenance` to `v2.1.60`.

## v2.1.59 (2026-04-16)

### Added
- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed
- chore: update CHANGELOG for v2.1.59

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: manual sync — apply SCALED Multi-Tenant V2 logic to repository README mapping
- chore: manual sync — apply SCALED Multi-Tenant V2 logic to CONTRIBUTING mapping
- chore: manual sync — apply SCALED Multi-Tenant V2 logic to root documentation
- chore: ai prompt sync — apply SCALED Multi-Tenant V2 logic to google-notebooklm schemas
- chore: ai prompt sync — apply SCALED Multi-Tenant V2 logic to repository core prompts
- chore: knowledge base sync — apply SCALED Multi-Tenant V2 definitions to incident reports
- chore: diagram sync — force 04 orchestrator labels in multi cloud topology
- chore: docs sync — apply SCALED Multi-Tenant V2 logic to analysis plans
- chore: end-of-day governance sync — 2026-04-16
- chore: end-of-day governance sync — 2026-04-15
- chore: update CHANGELOG for v2.1.57

### Fixed

- fix: correctly match legacy and multi-tenant edge lambda names in cleanup
- fix: purge cloudflare frontend record on network destroy

## v2.1.57 (2026-04-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.56

### Fixed


## v2.1.56 (2026-04-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.55

### Fixed


## v2.1.55 (2026-04-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for ASG teardown optimization
- chore: update changelog and integrate centralized knowledge base
- chore: update CHANGELOG for v2.1.54

### Fixed

- fix: correctly capture multi-tenant lambda edge names in orphaned cleanup

## v2.1.54 (2026-04-15)

### Added

- feat: bypass destructive ECS capacity provider reconciliation by default

### Changed

- chore: update CHANGELOG for v2.1.54
- chore: update CHANGELOG for v2.1.54
- chore: update CHANGELOG for v2.1.53

### Fixed

- fix(teardown): explicitly suspend ASG Launch processes before scaling down EC2 to prevent ECS managed scaling churn
- fix: correct ecr-login version in setup-blaze action

## v2.1.54 (2026-04-15)

### Added

- feat: bypass destructive ECS capacity provider reconciliation by default

### Changed

- chore: update CHANGELOG for v2.1.54
- chore: update CHANGELOG for v2.1.53

### Fixed


## v2.1.54 (2026-04-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.53

### Fixed


## v2.1.53 (2026-04-15)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.52

### Fixed


## v2.1.52 (2026-04-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.51

### Fixed


## v2.1.51 (2026-04-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.50

### Fixed


## v2.1.50 (2026-04-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.49

### Fixed


## v2.1.49 (2026-04-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.48

### Fixed


## v2.1.48 (2026-04-14)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-04-14
- chore: end-of-day governance sync — 2026-04-14
- chore: end-of-day governance sync — 2026-04-13
- chore: update CHANGELOG for v2.1.47
- chore: update CHANGELOG for v2.1.46
- chore: update CHANGELOG for v2.1.45
- chore: update CHANGELOG for v2.1.44
- chore: update CHANGELOG for v2.1.43

### Fixed


## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.


### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
- **CI/CD Maintenance**: Deep synchronization executed (Engine 6 & 8 checks passed).
- **Architecture**: Enforced Single-Tenant Elastic Beanstalk paradigm in AI prompts.
- **Hygiene**: Purged deploy temp directories globally.
- **Workflows**: Structurally aligned 90-daily-health-check.yml across Actions and Module Hub.

### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default
 - 2026-04-14

### Added
- feat(plan-135): **`enable_vpc_peering` input wired** through full reusable chain — `reusable-terraform.yml` gains new boolean input; when `true`, injects `TF_VAR_enable_vpc_peering=true` alongside the existing `TF_VAR_aws_account_id` auto-injection. `01-provision-infra.yml` threads the flag through `workflow_call` inputs to the `provision` job.
- feat(db-provisioning): **`reusable-provision-db-users.yml`** per-project isolation — uses canonical `STACK_KEY` to scope Atlas users per-project, preventing cross-tenant credential pollution.

### Changed
- chore(engine-4): **Engine 4 split-brain resolved (2026-04-14)** — `90-daily-health-check.yml` in blaze-actions fixed from `@v2.1.43` → `@v2.1.47`. `01g-provision-db-pod.yml` fixed from non-existent `@v2.1.50` → `@v2.1.47`.
- docs(WORKFLOW_CATALOG): bumped to v1.6.0 — added `01g-provision-db-pod` entry, deprecated `reusable-provision-db-users` for multi-site, updated total count 53→54, added v1.6.0 history entry.
- docs(ENVIRONMENT-ARCHITECTURE.md): added Multi-Site Architecture section (April 2026 two-pillar-v2 model — shared cluster, per-project isolation table, DB provisioning model, tenant onboarding guide).
- docs(agent-workflows): bumped timestamps from 2026-03-16 → 2026-04-14 on: `troubleshoot-cloudfront.md`, `debug-cicd-workflows.md`, `02-add-sharp-layer.md`, `troubleshoot-terraform-locks.md`.

### Security
- security(atlas): **`vpc-peering` module v2.3.4** — `mongodbatlas_project_ip_access_list.vpc_cidr` added, locks Atlas IP access to AWS VPC CIDR when peering active. Eliminates open `0.0.0.0/0` when private peering tunnel exists. `additional_cidr_allowlist` variable added with validation blocking `0.0.0.0/0`.


---

## v2.1.47 (2026-04-13)


### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.46
- chore: update CHANGELOG for v2.1.45
- chore: update CHANGELOG for v2.1.44
- chore: update CHANGELOG for v2.1.43

### Fixed


## v2.1.46 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.45
- chore: update CHANGELOG for v2.1.44
- chore: update CHANGELOG for v2.1.43

### Fixed


## v2.1.45 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.44
- chore: update CHANGELOG for v2.1.43

### Fixed


## v2.1.44 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.43

### Fixed


## v2.1.43 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.43
- chore: bump refs to v2.1.43
- chore: update CHANGELOG for v2.1.43
- chore: bump blaze-actions refs to v2.1.42
- chore: update CHANGELOG for v2.1.42

### Fixed

- fix(iam-policy-import): use jq -r instead of --output text for policy ARN lookup

## v2.1.43 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump refs to v2.1.43
- chore: update CHANGELOG for v2.1.43
- chore: bump blaze-actions refs to v2.1.42
- chore: update CHANGELOG for v2.1.42

### Fixed


## v2.1.43 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump blaze-actions refs to v2.1.42
- chore: update CHANGELOG for v2.1.42

### Fixed


## v2.1.42 (2026-04-13)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- docs: /13-deep-cicd-maintenance — fix WORKFLOW_CATALOG (count, dead refs, stubs→real descriptions), update REUSABLE_WORKFLOWS vars path, add CHANGELOG April 13
- chore: end-of-day governance sync — 2026-04-11
- chore: end-of-day governance sync — 2026-04-10
- chore: update CHANGELOG for v2.1.41

### Fixed

- fix(network): re-import Lambda@Edge IAM role+policy after state-rm
- fix(import): add DNS import-first pass for network/multi-site-network stacks

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default
 - 2026-04-13

### Documentation
- docs(WORKFLOW_CATALOG): corrected total workflow count (52→53), removed dead `stress-test.yml` reference (decomposed into reusable phases), removed non-existent `check-stack-exists.yml`, expanded all 16 stub entries with real descriptions, added 3 missing workflows (`lint-agent-workflows`, `deploy-gcp-site`, `reusable-provision-db-users`)
- docs(REUSABLE_WORKFLOWS): updated `vars/blaze-env.json` path to `vars/{project}/blaze-env.json` to reflect multi-project blaze-env layout; bumped timestamps to 2026-04-13

### Known Drift
- Engine 4: `v2.2.26` / `v2.2.28` split-brain on Azure and GCP stacks (not AWS). AWS stacks are all `v2.2.28`. Azure/GCP bump deferred until multi-cloud reprovision cycle.

---



### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.40

### Fixed


## [v2.1.41] - 2026-04-10

### Fixed
- `02-deploy-app.yml`: pin `02-deploy-aws.yml` from `@v2.1.38` to `@v2.1.40`.
  Completes project_slug fix chain: 02-deploy-app@v2.1.41 -> 02-deploy-aws@v2.1.40 -> calculate-config@v2.1.39.

## v2.1.40 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- fix(02-deploy-aws): update calculate-config pin to v2.1.39
- chore: update CHANGELOG for v2.1.39

### Fixed


## [v2.1.40] - 2026-04-10

### Fixed
- `02-deploy-aws.yml`: updated internal `calculate-config` pin from `@v2.1.27` to `@v2.1.39`
  so the new `project_slug` output is available in the `build-frontend` job BLAZE_GRAPHQL_URI formula.

## v2.1.39 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump to v2.1.39
- chore: update CHANGELOG for v2.1.38

### Fixed

- fix: add project_slug output to calculate-config and fix BLAZE_GRAPHQL_URI for multi-tenant sub-projects

## [v2.1.39] - 2026-04-10

### Added
- `calculate-config` action: added `project_slug` output (reads `PROJECT_SLUG` from `blaze-env.json`)

### Fixed
- `02-deploy-aws.yml`: corrected `BLAZE_GRAPHQL_URI` Docker build arg for multi-tenant sub-projects.
  Sub-projects (e.g. `support` with `PROJECT_SLUG=support`) now get the correct API URL
  (`api-{stage}-{slug}.{domain}`) instead of the primary project URL (`api-{client}-{stage}.{domain}`).


## v2.1.38 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump to v2.1.38
- chore: update CHANGELOG for v2.1.37

### Fixed


## v2.1.37 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump to v2.1.37
- chore: update CHANGELOG for v2.1.36

### Fixed


## v2.1.36 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump to v2.1.36
- chore: update CHANGELOG for v2.1.35

### Fixed


## v2.1.35 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump all workflow pins to v2.1.35
- chore: update CHANGELOG for v2.1.34

### Fixed


## v2.1.34 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump all workflow pins to v2.1.34
- chore: update CHANGELOG for v2.1.33

### Fixed


## v2.1.33 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump all workflow pins to v2.1.33
- chore: update CHANGELOG for v2.1.33
- chore: update CHANGELOG for v2.1.32

### Fixed

- fix(deploy-ecs-service): resolve CONTAINER_NAME before envsubst

## v2.1.33 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.32

### Fixed

- fix(deploy-ecs-service): resolve CONTAINER_NAME before envsubst

## v2.1.32 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.32
- chore: update CHANGELOG for v2.1.31

### Fixed


## v2.1.32 (2026-04-10)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.31

### Fixed


## v2.1.31 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.30

### Fixed


## v2.1.30 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.29

### Fixed


## v2.1.29 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.28

### Fixed


## v2.1.28 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- docs: update changelog for 13-deep-cicd-maintenance sync
- chore: update CHANGELOG for v2.1.27

### Fixed

- fix: sync internal workflow dependencies to v2.1.27

## v2.1.27 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.26

### Fixed

- fix: map admin_bucket in configuration job outputs so it is passed to Deploy Admin

## v2.1.26 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.25

### Fixed

- fix: bump all internal nested action references to v2.1.26 to prevent split-brain

## v2.1.25 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.24

### Fixed

- fix: resolve SHARED_HOST_PROJECT correctly in deploy-ecs-service to target the right ECS cluster

## v2.1.24 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.23
- chore: update CHANGELOG for v2.1.22
- chore: update CHANGELOG for v2.1.21

### Fixed

- fix: export admin_bucket explicitly to support multi-site V2 naming convention
- fix: bump internal references to v2.1.23 after YAML fix
- fix: correct YAML syntax error in calculate-config action outputs

## v2.1.23 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.22
- chore: update CHANGELOG for v2.1.21

### Fixed

- fix: bump internal references to v2.1.23 after YAML fix
- fix: correct YAML syntax error in calculate-config action outputs

## v2.1.22 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.21

### Fixed

- fix: correct YAML syntax error in calculate-config action outputs

## v2.1.21 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.20
- chore: update CHANGELOG for v2.1.19

### Fixed

- fix: explicit internal version bump to v2.1.21 across all internal references
- fix: Bump internal action references to v2.1.19/20

## v2.1.20 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.19

### Fixed

- fix: Bump internal action references to v2.1.19/20

## v2.1.19 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.18
- chore: update CHANGELOG for v2.1.17
- chore: update CHANGELOG for v2.1.16
- chore: update CHANGELOG for v2.1.15
- chore: end-of-day governance sync — 2026-04-09
- chore: end-of-day governance sync — 2026-04-09 (multi-tenant frontend routing slugs)
- docs: update CHANGELOG for end of day sync — 2026-04-08
- chore: end-of-day governance sync — 2026-04-08
- chore: allstop governance sync 2026-04-08 — §14 nuke incident patterns, version pin v2.2.16
- chore: allstop governance sync — 2026-04-08
- chore: update CHANGELOG for v2.1.14
- chore: update CHANGELOG for v2.1.13
- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed

- fix: Absolute path for reusable-terraform in 01-provision-infra

## v2.1.18 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.17
- chore: update CHANGELOG for v2.1.16
- chore: update CHANGELOG for v2.1.15
- chore: end-of-day governance sync — 2026-04-09
- chore: end-of-day governance sync — 2026-04-09 (multi-tenant frontend routing slugs)
- docs: update CHANGELOG for end of day sync — 2026-04-08
- chore: end-of-day governance sync — 2026-04-08
- chore: allstop governance sync 2026-04-08 — §14 nuke incident patterns, version pin v2.2.16
- chore: allstop governance sync — 2026-04-08
- chore: update CHANGELOG for v2.1.14
- chore: update CHANGELOG for v2.1.13
- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.17 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.16
- chore: update CHANGELOG for v2.1.15
- chore: end-of-day governance sync — 2026-04-09
- chore: end-of-day governance sync — 2026-04-09 (multi-tenant frontend routing slugs)
- docs: update CHANGELOG for end of day sync — 2026-04-08
- chore: end-of-day governance sync — 2026-04-08
- chore: allstop governance sync 2026-04-08 — §14 nuke incident patterns, version pin v2.2.16
- chore: allstop governance sync — 2026-04-08
- chore: update CHANGELOG for v2.1.14
- chore: update CHANGELOG for v2.1.13
- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.16 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.15
- chore: end-of-day governance sync — 2026-04-09
- chore: end-of-day governance sync — 2026-04-09 (multi-tenant frontend routing slugs)
- docs: update CHANGELOG for end of day sync — 2026-04-08
- chore: end-of-day governance sync — 2026-04-08
- chore: allstop governance sync 2026-04-08 — §14 nuke incident patterns, version pin v2.2.16
- chore: allstop governance sync — 2026-04-08
- chore: update CHANGELOG for v2.1.14
- chore: update CHANGELOG for v2.1.13
- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.15 (2026-04-09)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-04-09
- chore: end-of-day governance sync — 2026-04-09 (multi-tenant frontend routing slugs)
- docs: update CHANGELOG for end of day sync — 2026-04-08
- chore: end-of-day governance sync — 2026-04-08
- chore: allstop governance sync 2026-04-08 — §14 nuke incident patterns, version pin v2.2.16
- chore: allstop governance sync — 2026-04-08
- chore: update CHANGELOG for v2.1.14
- chore: update CHANGELOG for v2.1.13
- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## [2026-04-09] - calculate-config Per-Project State Split

### Changed
- feat(calculate-config): **Project-aware `multi-site-app-{project}` TF path resolution** — when `stack=multi-site-app` and `project != thisisblaze`, resolves to `live/multi-site-app-{project}` (or `{stage}-multi-site-app-{project}` for non-dev envs) with isolated S3 state key `infra/{project}/multi-site/app.tfstate`. Primary project (`thisisblaze`) uses canonical `multi-site-app` directory unchanged. Network + CDN stacks unaffected.

### Context
- Enables independent deploy and destroy of each project's app stack.
- Works in conjunction with `blaze-template-deploy` per-project stack dirs: `multi-site-app-support/`, `stage-multi-site-app-support/`, `prod-multi-site-app-support/`.

---

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default
 - 2026-04-10
- chore: end-of-day governance sync — 2026-04-10
- chore(cicd): /13-deep-cicd-maintenance — synced nested action representations to v2.1.41 across all internal workflows and updated documentation to reflect calculate-config as a composite action.
- fix(infra): hardened multi-site-app Terraform module to natively apply `/graphql` and `200,400` matcher for all API target groups.
- fix(actions): fully cascaded `project_slug` architecture bugfixes for multi-tenant DNS routing across multi-cloud ops code.
- build: Unified Terraform module tags to v2.2.27 across all deployments
- chore(cicd): /13-deep-cicd-maintenance — synced nested action representations to v2.1.27 across all internal workflows and resolved split-brain terraform module tag drift (v2.2.26 → v2.2.27)
- chore(cicd): /13-deep-cicd-maintenance — unified module pins to v2.2.20, fixed ECS task definition port 80 mappings

# Changelog

## [2026-04-08] - Engine 4/8 Split-Brain Resolution: GCP stacks + 90-daily-health-check

### Fixed
- fix(infra): bump 15 GCP live stacks in `blaze-actions` from `v2.2.14` → `v2.2.16` (all environments: dev/stage/prod network, app, data, cdn, multi-site)
- fix(infra): bump `aws/infra/preinit/main.tf` from `v2.2.14` → `v2.2.16`
- fix(90-daily-health-check.yml): replace stale `@v1.4.95` refs with `@v2.1.13` — Engine 8 parity fix

### Context
- Engine 4 (Module Versions) now green across all 3 repos: all Terraform stacks on `v2.2.16`
- Engine 8 (Workflow Parity) now green: `90-daily-health-check.yml` aligned across `blaze-actions` and `blaze-template-deploy`
- GCP stacks were the last remaining split-brain from the April 2026 `v2.2.16` governance sync

---

## [2026-04-08] - Plan 134 Phase 4: Multi-Tenant Documentation + Workflow Updates

### Added
- docs(13-deep-cicd-maintenance.md): multi-project awareness for `support` project — verify `calculate-config`, `deploy-ecs-service`, and reusable stress test workflows for hardcoded `thisisblaze` references

### Context
- Plan 134 Phase 4 complete: 13 files updated across `blaze-template-deploy` and `blaze-actions`
- `calculate-config` action verified already multi-project ready (reads `vars/${project}/blaze-env.json` generically)
- `support` project ECS services confirmed healthy (1/1, COMPLETED) on shared dev cluster

---

## [2026-04-08] - Module Ref Sync: v2.2.14 → v2.2.16

### Changed
- chore(infra): bump all `blaze-terraform-infra-core` module refs from `v2.2.14` → `v2.2.16` across 19 AWS live stacks (Engine 4 split-brain resolution). `blaze-template-deploy` was already at `v2.2.16`; this brings `blaze-actions` into parity. Both repos now agree on the same pinned tag.
  - v2.2.15: CI pin bump governance (`90-daily-health-check`)
  - v2.2.16: CloudFront descriptive comment strings in `environment-network` — cosmetic, non-breaking

---

## v2.1.14 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.13
- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.13 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.12
- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.12 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.11
- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.11 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.10
- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.10 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.9
- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.9 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.8
- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.8 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.7
- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.7 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.6
- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.6 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.5

### Fixed


## v2.1.5 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.4

### Fixed


## v2.1.4 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.3
- chore: update CHANGELOG for v2.1.2
- chore: update CHANGELOG for v1.4.96

### Fixed


## v2.1.3 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v2.1.2
- chore: update CHANGELOG for v1.4.96

### Fixed


## v2.1.2 (2026-04-07)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.96

### Fixed


## v1.4.96 (2026-04-05)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: prepare v1.4.96 release — stale ALB listener teardown fix
- chore: end-of-day governance sync — 2026-04-05
- chore: update CHANGELOG for v1.4.95
- chore: update CHANGELOG for v1.4.93
- chore: update CHANGELOG for v1.4.94

### Fixed

- fix(teardown): purge stale ALB listeners + Cloudflare DNS from state before destroy
- fix(v1.4.95): replace wrong CIDR fallback with Name tag in VPC discovery

## v1.4.96 (2026-04-05)

### Fixed
- fix(teardown): add **Purge Stale Network Resources** step to `reusable-terraform.yml` — runs only on destroy (AWS). Pre-nuke cleanup deletes the ALB (cascading all listener deletions) before Terraform destroy runs, leaving ALB stub listeners and Cloudflare ACM validation DNS records in state. Terraform then fails with `ListenerNotFound` and Cloudflare `404 Record does not exist`. New step `terraform state rm`s the three stale resources before plan. All removals use `|| echo` guards — fully idempotent, never fails when resources are still present (TF handles them normally). Root cause run: `23999146033` (dev-network, 2026-04-05).

---

## [2026-04-05] - Engine 4 Full Resolution & Module Ref Normalization

### Changed
- chore(infra): Normalize ALL `blaze-terraform-infra-core` module refs to `v2.2.14` across all live stacks (AWS, GCP). Eliminates Engine 4 split-brain (`v1.51.0`, `v2.1.1`, `v2.2.2` → `v2.2.14`). 33 files updated.
- chore(infra): Migrate `preinit/main.tf` from legacy `git::https://` format to modern `github.com//` source URL.

---

## v1.4.95 (2026-04-04)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.93
- chore: update CHANGELOG for v1.4.94

### Fixed

- fix(v1.4.95): replace wrong CIDR fallback with Name tag in VPC discovery

## v1.4.93 (2026-04-04)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.94

### Fixed


## v1.4.94 (2026-04-04)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: sweep @v1.4.70 → @v1.4.92 in 90-daily-health-check (Engine 4 drift fix)
- chore: update CHANGELOG for v1.4.92
- chore: update CHANGELOG for v1.4.91
- chore: update CHANGELOG for v1.4.90

### Fixed


## v1.4.94 (2026-04-04)

### Added
- feat(tag-taxonomy): introduce mandatory **Blaze Signature Tag** taxonomy across all live AWS Terraform stacks in `blaze-template-deploy` and `blaze-actions`:
  - Tags injected via AWS provider `default_tags` (Option A — provider-level, no infra-core module changes)
  - Tag set: `Blaze:Architecture=two-pillar-v2`, `Blaze:Provisioner=blaze-actions`, `Blaze:ManagedBy=terraform`, `Blaze:Project`, `Blaze:Environment`, `Blaze:Client`, `Blaze:Stack`, `Blaze:RunId`
  - `Blaze:RunId=$GITHUB_RUN_ID` enables per-run cost attribution and surgical tag-based cleanup
- feat(reusable-terraform): inject `TF_VAR_stack_name` (basename of tf_dir) and `TF_VAR_blaze_run_id` ($GITHUB_RUN_ID) in new **Inject Blaze Signature Tag Vars** step — auto-covers all stacks
- feat(variables): add `stack_name` + `blaze_run_id` variables with safe defaults to all AWS live stack `variables.tf`

### Changed
- feat(cleanup-vpc-orphans): VPC discovery upgraded to **tag-first** strategy using Blaze tags, with CIDR/Name fallback for older environments
- feat(99-nuke-env): Steps 4+5 use tag-first VPC discovery; Step 5 adds NAT GW + VPC-scoped EIP release before IGW detach
- chore(99-nuke-env): bump action pins `@v1.4.92` → `@v1.4.93`

## v1.4.93 (2026-04-04)

### Fixed
- fix(cleanup-vpc-orphans): **EIP scoping root cause** — `aws ec2 describe-addresses` has no `vpc-id` filter; account-wide query missed the IGW-mapped EIP causing `DependencyViolation`. New strategy: enumerate via NAT GW + EC2 + ENI→VPC client-side catch-all
- fix(cleanup-vpc-orphans): add **IGW unmap verification loop** (Step 2b) — poll until zero associated EIPs before Terraform destroy (max 60s)
- fix(cleanup-vpc-orphans): **two-pass SG cleanup** — Pass 1: revoke ALL rules across ALL SGs; Pass 2: delete all SGs. Eliminates circular SG reference failures
- fix(99-nuke-env): Step 4 upgraded to two-pass SG revoke-then-delete


## v1.4.92 (2026-04-03)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.91
- chore: update CHANGELOG for v1.4.90

### Fixed


## v1.4.92 (2026-04-03)

### Fixed
- fix(reusable-stress-test-teardown): add ECS trunk ENI drain poll loop (Step 0e) in `cleanup-vpc-orphans` — after `aws ec2 wait instance-terminated`, ECS control plane holds trunk ENIs for 2–5 min in awsvpc mode; new loop polls every 10s (max 5 min) until all trunk + ECS-description ENIs are released from the VPC, preventing `DependencyViolation` on subnet/IGW deletion in Destroy Network
- chore: bump `cleanup-vpc-orphans` `timeout-minutes` 15 → 20 to accommodate drain wait

## v1.4.91 (2026-04-03)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.90

### Fixed


## v1.4.91 (2026-04-03)

### Fixed
- fix(reusable-stress-test-verify): bump `reusable-verify-aws.yml` pin `@v1.4.37` → `@v1.4.90` — was referencing a 53-version-old pin, meaning the 20-min ECS stable-wait fix would never have been picked up at runtime

## v1.4.90 (2026-04-03)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.89

### Fixed


## v1.4.90 (2026-04-03)

### Fixed
- fix(reusable-verify-aws): increase ECS stable-wait timeout 600s → 1200s (10 min → 20 min) — root cause of run #23907200232 failure: Graviton ASG cold-starts from 0 on fresh provision; EC2 boot + ECS agent register + 300s instance_warmup_period = ~7 min before tasks can place, leaving only 3 min within the old 10-min window
- fix(reusable-verify-aws): bump job `timeout-minutes` 30 → 45 to accommodate the new 20-min ECS wait plus subsequent URL verification steps

## v1.4.89 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.88

### Fixed


## v1.4.89 (2026-04-02)

### Fixed
- fix(01-provision-infra): bump `reusable-terraform` pin from `@v1.4.65` → `@v1.4.88` to pick up S3 backend bootstrap step
- fix(reusable-stress-test-provision): bump all `01-provision-infra.yml` refs from `@v1.4.87` → `@v1.4.89`

## v1.4.88 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.87

### Fixed


## v1.4.88 (2026-04-02)

### Fixed
- fix(reusable-terraform): add "Bootstrap S3 Backend" step — idempotently creates the S3 state bucket and DynamoDB lock table before `terraform init` runs, solving the bootstrap chicken-and-egg for new environments (e.g., `multi-site`)

## v1.4.87 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.86

### Fixed


## v1.4.87 (2026-04-02)

### Fixed
- fix(01-provision-infra): bump internal `calculate-config` pin from `@v1.4.37` → `@v1.4.86` so the `multi-site` STAGE_KEY guard fix is actually executed at runtime
- fix(reusable-stress-test-provision): bump all `01-provision-infra.yml` refs to `@v1.4.87`

## v1.4.86 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.85

### Fixed


## v1.4.86 (2026-04-02)

### Fixed
- fix(calculate-config): add `multi-site` to the STAGE_KEY guard in multi-site-app/network/cdn dir resolution — prevents `multi-site-multi-site-app` double-prefix when `environment=multi-site`

## v1.4.85 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.84

### Fixed


## v1.4.85 (2026-04-02)

### Fixed
- fix(deploy/multi-site): add `app_stack` input to `reusable-stress-test-deploy.yml`; gate V1 `deploy-app` job on `app_stack != multi-site-app`
- feat(deploy/multi-site): add `deploy-multi-site` AWS job that discovers `site-NNN` ECS services by cluster query and force-deploys each one — bypasses missing task-def template issue; validates services exist post-provision

## v1.4.84 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.83

### Fixed


## v1.4.84 (2026-04-02)

### Fixed
- fix(teardown/post-destroy-state-fix): fix DynamoDB digest for ALL destroyed state files (network + app + tenant-app + db-pod-alpha) — was only fixing network.tfstate, causing checksum mismatch on app.tfstate
- fix(teardown/post-destroy-state-fix): add pre-check — skip if digest already correct to avoid redundant writes

## v1.4.83 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.82

### Fixed


## v1.4.83 (2026-04-02)

### Fixed
- fix(teardown/post-destroy-state-fix): new job after Destroy Network — syncs DynamoDB digest with actual S3 ETag so next provision never hits "state data in S3 does not have the expected content"
- fix(teardown/post-destroy-state-fix): new job deletes orphaned ECS Capacity Provider after destroy (blaze-*-ecs-ec2-cp survives Terraform destroy and blocks re-provision with AlreadyExists)

## v1.4.82 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.81

### Fixed


## v1.4.82 (2026-04-02)

### Fixed
- fix(teardown/cleanup-vpc-orphans): complete architectural rewrite of teardown order — add Step 0b (scale ECS services to 0) and Step 0c (delete ALBs/CLBs) which are the root cause of lb_sg + subnet DependencyViolation; LBs create ENIs in subnets and reference lb_sg blocking Terraform destroy
- fix(teardown/cleanup-vpc-orphans): simplify ASG VPC filter query to avoid JMESPath backtick escaping issues

## v1.4.81 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.80

### Fixed


## v1.4.81 (2026-04-02)

### Fixed
- fix(teardown/cleanup-vpc-orphans): suspend Graviton ASG scaling processes (Launch/Terminate/ReplaceUnhealthy/AZRebalance) + set desired=0 before instance termination — ASG was immediately relaunching replacement instances after terminate, re-associating fresh EIPs; suspension prevents this
- fix(teardown/cleanup-vpc-orphans): replace blind sleep 45s with aws ec2 wait instance-terminated — waits for actual termination confirmation instead of guessing

## v1.4.80 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.79

### Fixed


## v1.4.80 (2026-04-02)

### Fixed
- fix(teardown/cleanup-vpc-orphans): add Step 0 — terminate running EC2 instances in VPC before EIP/ENI cleanup — Graviton CP instances hold EIPs via instance-association which cannot be freed with disassociate-address while the instance is running; terminating first causes AWS to automatically release EIPs and detach ENIs cleanly

## v1.4.79 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.78

### Fixed


## v1.4.79 (2026-04-02)

### Fixed
- fix(teardown/cleanup-vpc-orphans): bump post-disassociate sleep 2s→10s + add 3-attempt retry loop on release-address — AWS disassociate-address is eventually consistent; the EIP remained "associated" for several seconds after the API returned, causing immediate release to fail and leaving the IGW with a mapped public address

## v1.4.78 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.77

### Fixed


## v1.4.78 (2026-04-02)

### Fixed
- fix(teardown/cleanup-vpc-orphans): disassociate EIPs before releasing (fixes IGW "mapped public address" detach error — EIPs still associated to ENIs were blocking IGW detach even after NAT GW deletion)
- fix(teardown/cleanup-vpc-orphans): force-detach ENI attachments before delete — ENIs held by ALB/ELB interfaces or other `in-use` attachments now have their `AttachmentId` force-detached (`--force`) before delete attempt, with 8s propagation wait
- fix(teardown/cleanup-vpc-orphans): revoke all SG ingress+egress rules before deletion — breaks circular SG references that prevent `DeleteSecurityGroup` even after ENI cleanup
- refactor: replace inline python3 with pure bash+AWS CLI (`--output text` + `while read`) — removes YAML linter false positives, no functional change to logic



### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.76

### Fixed


## v1.4.77 (2026-04-02)

### Fixed
- fix(teardown/cleanup-vpc-orphans): find VPC by CIDR (`10.4.0.0/16` for multi-site) instead of Name tag — tag lookup returned nothing because `terraform-aws-modules/vpc` sets the Name tag differently than expected. CIDR is hardcoded in `main.tf` and deterministic.
- fix(teardown/cleanup-vpc-orphans): add NAT Gateway deletion (Step 1) before ENI/SG cleanup — NAT GWs hold EIPs attached to the IGW and keep ENIs `in-use`, which was the real root cause of the `DependencyViolation` on subnet/IGW deletion. Also removed `status=available` filter from ENI cleanup (delete all ENIs in VPC after NAT GW is gone).

## v1.4.76 (2026-04-02)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-04-01
- chore: update CHANGELOG for v1.4.75

### Fixed


## v1.4.76 (2026-04-02)

### Fixed
- fix(teardown): add `cleanup-vpc-orphans` job — force-deletes orphaned ENIs, SGs, and EIPs before `destroy-network` runs. Root cause of run #23872243675 `DependencyViolation` on subnet/IGW deletion after app stack destroyed. Mirrors `99-nuke-env` Step 4. AWS-only, skips non-AWS providers.

## v1.4.75 (2026-04-01)

### Fixed
- fix(teardown): add `network_stack` input — `destroy-network` was targeting `dev-network` instead of `multi-site-network`; missing Cloudflare credentials (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID`, `CLOUDFLARE_ACCOUNT_ID`) caused `Invalid Attribute Value Match` error on Cloudflare provider during network destroy. Added `ACM_CERTIFICATE_ARN` forwarding.

## v1.4.74 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.73

### Fixed


## v1.4.73 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.72

### Fixed


## v1.4.72 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.71

### Fixed

- fix(destroy): pass ACM_CERTIFICATE_ARN to destroy ops — unblocks 30-min hang

## v1.4.71 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: sync 90-daily-health-check.yml — bump setup-blaze/calculate-config to v1.4.70
- chore: update CHANGELOG for v1.4.70

### Fixed


## v1.4.70 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: sync 90-daily-health-check.yml — bump setup-blaze/calculate-config to v1.4.69
- chore: sync 90-daily-health-check.yml from deploy repo (Engine 8 parity fix)
- chore: update CHANGELOG for v1.4.69
- chore: update CHANGELOG for v1.4.68
- chore: update CHANGELOG for v1.4.67

### Fixed


## v1.4.69 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.68
- chore: update CHANGELOG for v1.4.67

### Fixed


## v1.4.68 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.67

### Fixed


## v1.4.67 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.66
- chore: update CHANGELOG for v1.4.65

### Fixed


## v1.4.66 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.65

### Fixed


## v1.4.65 (2026-04-01)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed


### Fixed


## v1.4.65 (2026-04-01)

### Changed
- **01-provision-infra.yml**: Replace CF import strategy with delete-then-create. Orphaned Cloudflare resources (ZT Access Apps, DNS records) that exist in Cloudflare but not in TF state are now DELETED via API before plan, allowing TF to create them cleanly. This eliminates the account_id masking problem and import address complexity that caused repeated 81053/11010 failures.

## v1.4.64 (2026-04-01)

### Fixed
- **reusable-terraform.yml**: Add `working-directory: ${{ inputs.tf_dir }}` to the "Run Pre-Apply Script" step. Previously, `terraform import` commands in the pre-apply script ran in the runner's default working directory (missing `.terraform/`), causing all state imports to silently fail. This was the root cause of repeated Cloudflare error 81053 / 11010 on re-runs.

## v1.4.63 (2026-04-01)

### Fixed
- **01-provision-infra.yml**: Fix CF ZT app import — derive account_id from API response JSON to avoid GitHub secret masking (`TF_VAR_cloudflare_account_id` value was being masked to `***` in bash). Add comprehensive Cloudflare DNS record imports (api, api_direct, admin, frontend, cdn) to prevent error 81053 on re-runs.

## v1.4.62 (2026-04-01)

### Fixed
- **01-provision-infra.yml**: Broaden Cloudflare DNS validation record import to check all record types (not just CNAME). Fixes error 81053 on `cloudflare_dns_record.validation` when an existing record of any type blocks fresh creation.

## v1.4.61 (2026-04-01)

### Fixed
- **reusable-terraform.yml**: Remove `has_changes` apply gate. `terraform apply tfplan` is idempotent — no changes = fast no-op. Gate was broken because `PIPESTATUS[0]` returned 0 unexpectedly despite plan showing 64 resources to add.
- Add EXIT_CODE diagnostic print for future debugging.

## v1.4.60 (2026-04-01)

### Fixed
- **reusable-terraform.yml**: Fix apply gate — `env.has_changes` in step `if:` expressions is evaluated at job-start (frozen), never updated between steps. Now emits `has_changes` as a **step output** (`steps.plan.outputs.has_changes`) which IS evaluated dynamically. This was the root cause of Terraform apply being permanently skipped despite plan detecting 64 resources to add.

## v1.4.59 (2026-04-01)

### Fixed
- **reusable-terraform.yml**: Fix critical `tee plan.log` flush race condition — `has_changes` now driven by `EXIT_CODE` from `-detailed-exitcode` (2=changes) instead of grep timing. Prevents apply being skipped when Terraform detects 64 resources to add but plan.log hasn't flushed yet.

## v1.4.58 (2026-04-01)

### Fixed

- fix(nuke): state-rm all tenant-app resources before destroy plan — prevents terraform plan -destroy from failing when SSM network params are already gone (19 missing params: vpc_id, subnets, cluster, ALBs, CF functions, etc.)
- fix(nuke): remove `!contains(needs.*.result, 'failure')` global gate from `nuke-destroy-data-aws` and `nuke-destroy-network-aws` — the Gate job already absorbs app-stack failures; the redundant check was blocking the network destroy when tenant-app failed

## v1.4.57 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.56
- chore: update CHANGELOG for v1.4.55
- chore: update CHANGELOG for v1.4.54
- chore: update CHANGELOG for v1.4.53
- chore: update CHANGELOG for v1.4.52
- chore: update CHANGELOG for v1.4.51
- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-cp): deregister container instances before detaching CP
- fix(ecs-cp): use temp file to capture detach stderr (bash -e safe)
- fix(ecs-cp): retry detach 5x — DEPROVISIONING tasks block PutClusterCP
- refactor(dns): pivot from delete-first to import-first for Cloudflare records
- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.56 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.55
- chore: update CHANGELOG for v1.4.54
- chore: update CHANGELOG for v1.4.53
- chore: update CHANGELOG for v1.4.52
- chore: update CHANGELOG for v1.4.51
- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-cp): use temp file to capture detach stderr (bash -e safe)
- fix(ecs-cp): retry detach 5x — DEPROVISIONING tasks block PutClusterCP
- refactor(dns): pivot from delete-first to import-first for Cloudflare records
- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.55 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.54
- chore: update CHANGELOG for v1.4.53
- chore: update CHANGELOG for v1.4.52
- chore: update CHANGELOG for v1.4.51
- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-cp): retry detach 5x — DEPROVISIONING tasks block PutClusterCP
- refactor(dns): pivot from delete-first to import-first for Cloudflare records
- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.54 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.53
- chore: update CHANGELOG for v1.4.52
- chore: update CHANGELOG for v1.4.51
- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-cp): retry detach 5x — DEPROVISIONING tasks block PutClusterCP
- refactor(dns): pivot from delete-first to import-first for Cloudflare records
- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.53 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.52
- chore: update CHANGELOG for v1.4.51
- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- refactor(dns): pivot from delete-first to import-first for Cloudflare records
- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.52 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.51
- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- refactor(dns): pivot from delete-first to import-first for Cloudflare records
- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.51 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.50
- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-cp): pivot to detach+delete orphan CPs instead of import
- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.50 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.49
- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.49 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.48
- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(ecs-import): dynamic CP name discovery instead of hardcoded suffix
- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.48 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.47
- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(01-provision-infra): drain ECS tasks before PutClusterCapacityProviders update
- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.47 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.46
- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed

- fix(01-provision-infra): replace ECS state-rm with import strategy in pre_apply_script

## v1.4.46 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.45
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed


## v1.4.45 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed


## v1.4.44 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.44
- chore: update CHANGELOG for v1.4.43

### Fixed


## v1.4.44 (2026-03-31)

### Fixed

- fix(import): add orphan ASG force-delete (both ec2-cp and graviton-cp) for post-nuke reprovision
- fix(import): expand LT cleanup to cover graviton-cp-lt
- fix(01-provision-infra): correct stale .ec2[0] → .ecs[0] module paths in zombie state-rm block

## v1.4.44 (2026-03-31)

### Fixed

- fix(import): add orphan ASG force-delete (both ec2-cp and graviton-cp) for post-nuke reprovision
- fix(import): expand LT cleanup to cover graviton-cp-lt
- fix(01-provision-infra): correct stale .ec2[0] → .ecs[0] module paths in zombie state-rm block

## v1.4.43 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.43
- chore: update CHANGELOG for v1.4.42

### Fixed

- fix(import): add orphan ECS cluster, Launch Template + TG delete-fallback for post-nuke reprovision

## v1.4.43 (2026-03-31)

### Fixed

- fix(import): orphan ECS cluster, Launch Template + TG delete-fallback for post-nuke reprovision — prevents AlreadyExists/ResourceInUseException on next provision

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.41
- chore: update CHANGELOG for v1.4.40

### Fixed


## v1.4.41 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.40

### Fixed


## v1.4.40 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.39
- chore: update CHANGELOG for v1.4.38

### Fixed


## v1.4.39 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.38

### Fixed


## v1.4.38 (2026-03-31)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.37

### Fixed


## v1.4.37 (2026-03-30)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.37
- chore: update CHANGELOG for v1.4.36

### Fixed

- fix: auto-upgrade generic network and app stacks to multi-site-v2
- fix: route multi-site stacks to proper environment scopes

## v1.4.37 (2026-03-30)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.36

### Fixed

- fix: route multi-site stacks to proper environment scopes

## v1.4.36 (2026-03-30)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.35

### Fixed

- fix: remove invalid required: false under secrets

## v1.4.35 (2026-03-30)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: V2 architecture UX visibility refactor (tenant vs multi-site)
- chore: end-of-day governance sync — 2026-03-29
- chore: bump internal refs to v1.4.34
- chore: update CHANGELOG for v1.4.34

### Fixed

- fix: explicit mappings for multi-site stacks in calculate-config
- fix: resolve split-brain by syncing infra-core refs to v2.2.2

## v1.4.34 (2026-03-29)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: prepare v1.4.34 release — lowercase env options, fixes NPM_TOKEN in stage builds
- chore: update CHANGELOG for v1.4.33

### Fixed


## [v1.4.34] - 2026-03-29

### Fixed

- Lowercase environment option values (DEV→dev, STAGE→stage, PROD→prod) in `02-deploy-aws.yml`
- All string comparisons updated to match lowercase convention
- Fixes NPM_TOKEN being empty in build jobs: GitHub named environments are case-sensitive;
  passing 'STAGE' created a blank environment with no secrets instead of resolving to
  the 'stage' environment that has NPM_TOKEN configured

## v1.4.33 (2026-03-29)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: bump internal refs to v1.4.33 — EC2 launch type for STAGE stress test
- chore: update CHANGELOG for v1.4.32

### Fixed


## v1.4.33 (2026-03-29)

### Fixed
- fix(stress-test): Use EC2 launch type for STAGE environment in `reusable-stress-test-provision.yml`.
  STAGE uses the same ARM64 EC2 cluster architecture as PROD. The previous condition only mapped
  `prod` to EC2, causing STAGE to attempt FARGATE deployments on an EC2-only ECS cluster.



### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: prepare v1.4.32 release — fix calculate-env-config app→tenant-app routing for STAGE
- chore: end-of-day governance sync — 2026-03-28
- chore: end-of-day governance sync — 2026-03-28
- chore: end-of-day governance sync — 2026-03-28
- chore: end-of-day governance sync — 2026-03-27
- docs: end-of-day changelog update — 2026-03-27
- chore: end-of-day governance sync — 2026-03-26
- chore: end-of-day governance sync — 2026-03-25
- docs: Multi-Site V2 governance sync 2026-03-25
- chore: end-of-day governance sync — 2026-03-24
- docs: modernization update ecosystem action pin mapping to @v1.4.31
- docs: modernization sweep replacing @v1.4.0 execution pins with standard @v1.4.31 baseline
- chore: end-of-day governance sync — 2026-03-23
- docs: agent workflow optimizations — bash grep eradication & python port
- docs: agent workflow sync to remove hardcoded templates
- chore: remove frontend Check Engines trigger (moved to deploy repo)
- chore: move checkengines to 9X maintenance namespace
- chore: update CHANGELOG for v2.1.1

### Fixed

- fix: skip admin pages deployment on GCP to align with Two-Pillar architecture

## v1.4.32 (2026-03-29)

### Fixed
- fix(calculate-env-config): Auto-route `app` stack to `stage-tenant-app` for STAGE environment, resolving persistent `data.aws_lb_target_group.frontend_blue` / `api_blue` "couldn't find resource" errors in the Multi-Site V2 stress test provisioning pipeline.
- fix(orchestrator): Rerouted `app` deployments to `tenant-app` and injected the `db-pod-alpha` data layer to align CI/CD stress tests with the Multi-Site V2 Two-Pillar architecture.
- fix(ci): Resolved Terraform state split-brain by permanently replacing `@dev` action references with `@v1.4.30` across all deployment pipelines.
- fix(ci): Reordered Terraform dependency graph in `reusable-stress-test-provision.yml` to ensure data pods natively provision BEFORE application modules.
- fix(aws/network): Disabled `split_apply` for network stack now that Terraform module-level cyclic dependencies are patched, bypassing empty diff apply skips.
- fix(orchestration): Support targeted Terraform plan for split applies to bypass TF dependency graph errors.

### Changed
- chore: Synced `90-daily-health-check.yml` structural parity natively across all 3 repos.
- chore: Purged orphaned `scratch/` directories to pass `/checkengines` hygiene protocols.
- chore: end-of-day governance sync — 2026-03-29

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default
 - 2026-03-27

### Fixed
- **GCP Deployments:** Patched `02-deploy-pages.yml` to explicitly skip Admin Cloudflare Pages deployments on GCP tenant environments, enforcing the Pillar 1 (Core) vs Pillar 2 (Tenant) boundaries.
- **Azure Deployments:** Excised orphaned `build-admin` job from `02-deploy-azure.yml` to resolve `409 Conflict` artifact collisions.
- **Pages Deployments:** Silenced `jq` JSON parse crashes on `02-deploy-pages.yml` by introducing native bash fallback processing during 404 project lookups.
- **Azure Orchestration:** Injected `--no-wait` flags into the `99-ops-nuke.yml` Container Apps deletion scripts to bypass 15-minute Github Action pipeline timeouts.

### Changed
- chore: end-of-day governance sync — 2026-03-27

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default
 - 2026-03-26

### Changed
- chore: end-of-day governance sync — 2026-03-26

### Fixed
- fix(ci): Implemented dynamic ACM certificate ARN resolution in `reusable-terraform.yml` to support multi-site environments without static secrets.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default
 - 2026-03-25### Changed
- chore: end-of-day governance sync — 2026-03-25
- docs: Complete Multi-Site V2 architecture documentation rewrite (Two-Pillar strategy).
- infra: Decoupled CloudFront API distribution from Frontend.

### Fixed
- fix: Parameterized SSM target path in reusable-provision-db-users for Multi-Site V2 tenant decoupling.

## v2.1.1 (2026-03-23)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-03-22
- chore: bump terraform modules to v2.2.0
- chore: align module references to v2.1.2 (fix split brain)
- chore: end-of-day governance sync — 2026-03-22
- chore: update CHANGELOG for v1.4.31

### Fixed


## v1.4.31 (2026-03-22)

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


### Added
- feat(ops): Implement 10-engine checkengines workflow routing via pure python.
- feat(ai): Restored `/checkengines` slash command natively.

### Changed
- docs: Agent workflow optimizations — eradicated bash `grep` loops across orchestrators in favor of native Python and generic JSON parsers.
- build(deps): Upgrade checkengines tracking and lock all terraform templates to `v1.51.0` semantic release.
- build(deps): Bumped `actions/checkout` and `actions/setup-python` from v4/v5 to v6.
- chore: bump internal workflow module references to v2.2.0 to consume new database user CLI logic.
- feat(ci): Simplified the `01-provision-infra.yml` workflow dropdown by removing unused `data`, `cdn`, and `tunnel` options to streamline provisioning.
- chore: Move checkengines to 9X maintenance namespace.

### Fixed
- fix(ops): Run destroy safely when pre-cleanup skips.
- fix(ci): Sync 90-daily-health-check.yml globally after semantic version updates.
- fix(infra): Add `admin-spa` and `frontend-spa` buckets to the pre-destroy cleanup script to avoid `BucketNotEmpty` S3 errors.

## v1.4.31 (2026-03-22)

### Fixed
- **Teardown**: Removed standard execution roles from force-deletion paths during `reusable-pre-destroy-cleanup` to resolve ECS PENDING locks on preserved networks.

## v1.4.30 (2026-03-21)

- chore: bump internal workflow references to v1.4.30 (5fc7676)
## v1.4.29 (2026-03-21)

- fix(deploy): remove aws iam get-role polling loop due to OIDC Access Denied constraints (1d18f1b)
- chore: end-of-day governance sync — 2026-03-21 (f1f7994)
- feat(ci): remove unused data, cdn, and tunnel options from infra dropdown (c17f280)
- fix(infra): resolve undefined variables missed during manual dev clone (0a87e17)
- fix(infra): scrub residual stage strings from dev clone (ff18360)
- fix(infra): remove hardcoded stage paths from remote state lookups (13c251c)
- feat(infra): clone stage architecture to dev while disabling WAF and NAT (29a50b6)
- fix(infra): restore all live terraform environments wiped in a44b330 (a7f2461)
- chore: update CHANGELOG for v1.4.28 (f573204)
# Changelog

## v1.4.65 (2026-04-01)

### Changed
- **01-provision-infra.yml**: Replace CF import strategy with delete-then-create. Orphaned Cloudflare resources (ZT Access Apps, DNS records) that exist in Cloudflare but not in TF state are now DELETED via API before plan, allowing TF to create them cleanly. This eliminates the account_id masking problem and import address complexity that caused repeated 81053/11010 failures.

## v1.4.64 (2026-04-01)

### Fixed
- **reusable-terraform.yml**: Add `working-directory: ${{ inputs.tf_dir }}` to the "Run Pre-Apply Script" step. Previously, `terraform import` commands in the pre-apply script ran in the runner's default working directory (missing `.terraform/`), causing all state imports to silently fail. This was the root cause of repeated Cloudflare error 81053 / 11010 on re-runs.

## v1.4.63 (2026-04-01)

### Fixed
- **01-provision-infra.yml**: Fix CF ZT app import — derive account_id from API response JSON to avoid GitHub secret masking (`TF_VAR_cloudflare_account_id` value was being masked to `***` in bash). Add comprehensive Cloudflare DNS record imports (api, api_direct, admin, frontend, cdn) to prevent error 81053 on re-runs.

## v1.4.62 (2026-04-01)

### Fixed
- **01-provision-infra.yml**: Broaden Cloudflare DNS validation record import to check all record types (not just CNAME). Fixes error 81053 on `cloudflare_dns_record.validation` when an existing record of any type blocks fresh creation.

## v1.4.61 (2026-04-01)

### Fixed
- **reusable-terraform.yml**: Remove `has_changes` apply gate. `terraform apply tfplan` is idempotent — no changes = fast no-op. Gate was broken because `PIPESTATUS[0]` returned 0 unexpectedly despite plan showing 64 resources to add.
- Add EXIT_CODE diagnostic print for future debugging.

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


### Changed
- feat(ci): Simplified the `01-provision-infra.yml` workflow dropdown by removing unused `data`, `cdn`, and `tunnel` options to streamline provisioning.

## v1.4.28 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.27

### Fixed


## v1.4.27 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.26

### Fixed


## v1.4.26 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.25

### Fixed


## v1.4.25 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.24

### Fixed


## v1.4.24 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.23
- chore: update CHANGELOG for v1.4.22
- chore: update CHANGELOG for v1.4.21

### Fixed


## v1.4.23 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.22
- chore: update CHANGELOG for v1.4.21

### Fixed


## v1.4.22 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.21

### Fixed


## v1.4.21 (2026-03-21)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: end-of-day governance sync — 2026-03-20
- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.18

### Fixed


## v1.4.20 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.18

### Fixed


## v1.4.19 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.18

### Fixed


## v1.4.20 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.20
- chore: update CHANGELOG for v1.4.19

### Fixed


## v1.4.20 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.19

### Fixed


## v1.4.19 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.19
- chore: update CHANGELOG for v1.4.18

### Fixed


## v1.4.19 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.18

### Fixed


## v1.4.18 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.17

### Fixed


## v1.4.17 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.16

### Fixed


## v1.4.16 (2026-03-20)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.15

### Fixed


## v1.4.15 (2026-03-20)

### Added

- feat: migrate third-party DB users to GitHub Actions CLI

### Changed

- chore: bump blazecore environment network dependencies to v2.0.0 for v6 upgrade testing
- refactor: pipe basic_auth_credentials via GitHub secrets
- chore: end-of-day governance sync — 2026-03-20 [MacBook Pro]
- chore: bump aws-actions for Node 24 support
- chore: end-of-day governance sync — 2026-03-18
- chore: update CHANGELOG for v1.4.14

### Fixed

- fix: bump trivy-action to v0.28.0 to support Node 20+
- fix: pass missing domain_root to verification workflows
- fix: inject timeout-minutes and pin github action shas globally

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-20

### Changed
- chore: sync `dev-mini-network` and `dev-network` module refs to v1.55.2 to resolve split brain.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-19

### Changed
- fix: Inject `timeout-minutes: 30` across all jobs to prevent runaway billing traps.
- security: Pin all top-level GitHub Actions to specific SHA hashes to prevent supply chain poisoning.
- feat: Add `deploy-gcp-site.yml` for GCP multi-site orchestrated deployments.

## v1.4.14 (2026-03-18)

### Changed

- chore: sync all internal blaze-actions pointers to v1.4.14 to inherit native Node 24 Docker actions

## v1.4.13 (2026-03-18)

### Changed

- chore: bump docker/build-push-action to v7 and setup-buildx to v4 for Node 24 support

## v1.4.12 (2026-03-18)

### Changed

- chore: bump aws-actions/configure-aws-credentials in composite actions to v6.0.0 for Node 24 support

## v1.4.11 (2026-03-18)

### Changed

- chore: inject FORCE_JAVASCRIPT_ACTIONS_TO_NODE24 in setup-blaze and point workflows to dev to suppress node 20 deprecation
- chore: explicitly export CLOUD_PROVIDER in reusable workflows to prevent false heuristics

### Fixed

- fix(ci): remove overly aggressive add-mask that breaks terraform output wrapper

## v1.4.10 (2026-03-18)

### Changed

- docs: session handoff — 2026-03-18
- chore: end-of-day governance sync — 2026-03-18

## v1.4.9 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.8
- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.9 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.8
- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.9 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.8
- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.9 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.8
- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.9 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.9
- chore: update CHANGELOG for v1.4.8
- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.9 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.8
- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.8 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.8
- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.8 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- docs: add findings on GitHub Actions cross-org relative path resolution bug
- chore: update CHANGELOG for v1.4.7

### Fixed


## v1.4.7 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.6
- chore: update CHANGELOG for v1.4.5
- chore: update CHANGELOG for v1.4.4

### Fixed


## v1.4.6 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.5
- chore: update CHANGELOG for v1.4.4

### Fixed


## v1.4.5 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.4

### Fixed


## v1.4.4 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.3

### Fixed


## v1.4.3 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.2
- chore: update CHANGELOG for v1.4.1

### Fixed


## v1.4.2 (2026-03-18)

### Added

- No new features in this release

### Fixed

- `01-provision-infra.yml`: bump `reusable-terraform.yml` pin `v2.1.86` → `v2.1.88` (CF token EOF fix)

### Changed

- chore: update CHANGELOG for v1.4.1

### Fixed


## v1.4.1 (2026-03-18)

### Added

- feat: Add fast-fail check for missing ECS clusters

### Changed

- docs: agent workflow tech debt resolution and hygiene sweep 2026-03-17
- chore: end-of-day governance sync — 2026-03-17
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026
- docs: session handoff — 2026-03-16 [Mac — GCP CDN Destroy Bugfix & Check Engines]
- chore: update CHANGELOG for v1.4.0

### Fixed


## v1.4.0 (2026-03-16)

### Added

- feat: handle orphaned target groups, log groups, and cloudfront functions in cleanup script
- feat: add cleanup-orphaned-buckets ops action
- feat: Add job to deploy Admin SPA to S3
- feat: add gcp stress test workflow
- feat: add skip_stability_wait to ECS deploy action + wire through stress-test
- feat: add Azure to daily health check (Gap 14)
- feat: add S3 endpoint override for GCS compatibility
- feat: wire all env vars + secrets to GCP Cloud Run deploy
- feat: add environment input to docker build
- feat: Add dynamic bucket logic to 00 and pass wif_audience in reusables
- feat: add wif_audience input to support custom WIF audience for GCP auth
- feat: enable auto-cleanup for app stack resources (pages/workers)
- feat: add cleanup-dns and nuke-cloudfront to ops utility
- feat: enable split apply for tunnel stack in provision workflow
- feat: implement split apply for tunnel stability and release v1.3.0
- feat: add Azure auth guard to 01-provision-infra.yml
- feat: GCP CI/CD parity — cloud_provider routing, data stack, provider-aware summaries
- feat: multi-cloud guards for setup, state utils
- feat: multi-cloud awareness for auxiliary workflows
- feat: multi-cloud guards for all ops-utility jobs
- feat: guard remaining AWS-only jobs + GCP nuke teardown
- feat: complete multi-cloud wiring in 02-deploy-app
- feat: GCP compute deploy + multi-cloud configuration job
- feat: add GCP Artifact Registry auth to docker-build workflow
- feat: wire GCP config end-to-end through calculate-config
- feat: add GCP WIF secrets to reusable-terraform
- feat: multi-cloud router foundation (Phase 1A+1B)
- feat: add cloudwatch log cleanup to pre-destroy workflow
- feat: Support resolving distribution ID from domain name in fix-cname-conflict
- feat: enable multi-arch build and hybrid ecs for frontend
- feat: add EC2 cleanup to pre-destroy + update NotebookLM prompts
- feat: add account-settings stack support + hybrid ECS docs
- feat: update deploy call chain for multi-arch and hybrid ECS
- feat: multi-arch Docker builds and hybrid ECS deploy support

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- chore: end-of-day governance sync — 2026-03-16
- chore: align dev and dev-mini network module refs to v1.55.1
- chore: end-of-day governance sync — 2026-03-12
- docs: session handoff — 2026-03-12 governance updates
- chore: end-of-day governance sync and session handoff - 2026-03-11
- chore: end-of-day governance sync — 2026-03-11
- docs: freeze AI session state for Node 20 / NPM 404 patches
- chore: globally upgrade actions/checkout and actions/setup-node to v5
- docs: generate HANDOFF.md freezing session context for Run 19
- refactor: remove stress-test.yml and variations due to github 4-level nesting limit
- Refactor: Decompose monolithic stress test into phase orchestrators to bypass 20-ref limit [skip ci]
- docs: end-of-day governance sync and AI Context updates
- docs: 09-maintain-docs monthly sweep 2026-03-04
- chore: add reusable noop for testing parser
- chore: fix checkengines false positives and turbo annotations
- chore: save handoff state for next session
- docs: handoff state frozen 2026-03-04T08:22Z
- docs: session handoff — 2026-03-04 [Antigravity Azure]
- chore: automate docs freshness and hygiene maintenance
- docs: sync handoff state before 120 cf distributions architecture pivot
- docs: add image resize troubleshooting guide for CloudFront 403 and Lambda 404 errors
- chore: session handoff state — CloudFront deletion forensics complete
- chore: end-of-day governance sync — 2026-03-01
- chore: end-of-day governance sync — 2026-03-01
- chore: integrate ENV_COMPARISON_AWS report into all governance workflows
- chore: increase ECS service wait timeout from 5 to 10 mins
- chore: handoff 2026-02-28 — dev-network v1.50.8 applied, stress test pending
- chore: sync module refs to v1.50.3 and update ops utility for dev-mini
- chore: end-of-day governance sync 2026-02-28 — Section 11 (dual-ALB facts, VPC CIDRs, v1.50.3)
- docs: update system prompt and NotebookLM docs for separate API ALB architecture
- docs: sync blaze-actions with 2026-02-27 architecture changes
- docs: sync agent workflows and workflow catalog with dev-mini and dev parity changes
- docs: generate HANDOFF state for native ECS Blue/Green stress test
- docs: redact internal AWS profile from handoff
- chore: add log and txt files to .gitignore
- docs: AWS focus state update
- docs: generate handoff state
- chore: save end-of-month audit handoff session state
- chore: end-of-day governance sync — 2026-02-25
- chore: test mid workflow
- chore: save AI session handoff state
- chore: end-of-day governance sync — 2026-02-25
- chore: end-of-day governance sync — 2026-02-25
- chore: end-of-day governance sync — 2026-02-25
- chore: end-of-day governance sync — 2026-02-25
- chore: end-of-day governance sync — 2026-02-24
- chore: end-of-day governance sync — 2026-02-24
- chore: end-of-day governance sync — 2026-02-23
- docs: add strict public repository sanitization constraints to AI rules
- docs: create native knowledge library for smart ops fixes
- docs: add skip_stability_wait to CHANGELOG
- docs: refresh stale NotebookLM Last Updated dates (checkengines Engine 1) 📄
- docs: add workflow metadata descriptions for Engine 8 parity
- chore: end-of-day governance sync — 2026-02-21
- chore: unified governance — one ring to rule them all
- docs: multi-cloud updates to WORKFLOW_CATALOG (version, state backends, deploy platforms)
- chore: remove debug steps for gcp secrets
- chore: debug gcp secrets
- chore: trigger workflow refresh
- chore: test commenting out workflow_call secret
- chore: add debug credentials step
- chore: remove debug job
- chore: add debug job for failure context
- docs: standardize contributing guide and add PR template
- docs: update README to v1.2.0-multi-cloud-foundation
- docs: add v1.2.0-multi-cloud-foundation to CHANGELOG
- docs: update notebooklm prompt with hybrid ecs and cleanup details
- docs: refine reusable-pre-destroy-cleanup description
- docs: update reusable workflows guide with multi-cloud and cleanup
- docs: add multi-cloud secrets to cross-org guide
- docs: add multi-cloud topology diagram
- docs: update AI governance with multi-cloud and cleanup protocols
- docs: update quick start audit prompt with cleanup protocols
- docs: update daily audit prompt with cleanup workflow checks
- docs: update system prompt with cleanup protocols
- docs: daily audit update [2026-02-16]
- docs: update README for multi-cloud support (AWS + GCP + Azure)
- chore: Automate Governance Context loading and update NAT Strategy
- chore: update version to v1.1.0-hybrid-ecs
- docs: install maintain-docs workflow and sweep report
- docs: update NotebookLM prompts — v1.4.0 → v1.33.2 workflow refs, ECS Fargate → Hybrid, dates → 2026-02-09
- docs: fix duplicate Workflow Catalog link, update dates in REUSABLE_WORKFLOWS.md
- docs: add enable_ec2, api_launch_type, cpu_architecture to WORKFLOW_CATALOG
- docs: add v1.1.0-hybrid-ecs changelog, update README version
- docs: monthly documentation audit — February 2026
- chore: update CHANGELOG for v1.0.0-fargate-stable

### Fixed

- fix: Correct secrets indentation in reusable workflows
- fix: pass BLAZE_ELASTICSEARCH_ENDPOINT correctly to pages deploy
- fix: pass BLAZE_ELASTICSEARCH_ENDPOINT correctly to cloud run and azure container apps
- fix: skip VPC Integrity Check on terraform destroy
- fix: pass NODE_AUTH_TOKEN explicitly as a build-arg to fix Lerna NPM authentication bug in docker builds
- fix: switch back to setup-node registry-url and pass NODE_AUTH_TOKEN to fix Lerna bug natively
- fix: pass NODE_AUTH_TOKEN directly to build:admin to bypass lerna npmrc bug
- fix: remove setup-node registry-url override to allow custom .npmrc for lerna
- fix: resolve yaml syntax and job requirement errors in 99-ops-cloudflare
- fix: resolve unrecognized named-value 'secrets' in deploy-site if conditional
- fix: resolve yaml syntax and job requirement errors in 99-ops workflows
- fix: correct ACR naming convention order (stage before project_key)
- fix: add missing wif_audience to teardown and verify workflows for GCP auth
- fix: skip AWS credential config and resources cleanup for azure/gcp runs
- Fix: correct input parameter mismatches in verification phase and Azure caller
- fix(nuke/network): move state rm to pre_apply_script (before plan) — fix stale plan
- fix(pre-destroy): add CloudFront distribution and cache policy pre-destroy cleanup
- fix: strictly scope ops cleanup script to thisisblaze project only
- fix: match project_key in bucket cleanup
- fix(99-ops-utility): remove empty GCP audience field causing invalid_grant on nuke
- fix: add MULTI-SITE to stress-test workflow options
- fix: re-index VPC CIDRs for stage, prod, and multi-site
- fix: re-index VPC CIDRs (0=dev:10.0, 1=dev-mini:10.1, 2=stage:10.2, 3=prod:10.3, 4=multi:10.4)
- fix: explicitly pass AWS_ROLE_ARN instead of secrets: inherit to prevent resolution failure when called from other respositories
- fix: update stress-test stability check for native ECS blue/green
- fix: skip Cloudflare Pages admin deployment when AWS is used
- fix: add missing cloudflare and mongodb secrets to all azure stress test jobs
- fix: correct azure conditional and remove always() clause from initial destroy steps
- fix(azure): pass GH_PAT via reversed job output chain to reach reusable-terraform-operations
- fix(azure): use infra_prefix for tf_dir instead of hardcoded 'infra/project/stage' path
- fix(azure): switch from base64 to rev encoding for cross-env secret bridge
- fix(azure): pass cloud-provider to setup-blaze in reusable-terraform-operations
- fix(azure): uppercase environment name for blaze-actions env gates (startup_failure fix)
- fix(gcp-multi-site): resolve Artifact Registry repo name mismatch
- Fix: Add SSH deploy key fallback for private Terraform module access (GH_PAT → DEPLOY_KEY → GITHUB_TOKEN)
- Fix: NAMESPACE default in blaze-env.json, optional jq chaining, and add default fallbacks in calculate-config
- fix: actionlint gcp issues
- docs(knowledge): extend OIDC guide with cross-repo vars fallback pattern
- fix: auto-upload test image before image resize verification
- fix: CDN domain is cdn.domain for prod, cdn-env.domain for others
- fix: add Cloudflare secrets to destroy-app calls
- fix: add missing stage_key to all terraform operations calls
- fix: gate tunnel provisioning/destroy to DEV-only in stress test
- fix: pass launch_type/cpu_architecture to deploy-app in stress test
- fix(azure): authenticate git before TF init in post_provision_azure_cdn
- fix: pass STACK_NAME to pre_apply_script
- fix: update frontend gcp deploy image uri
- fix: use env vars for secrets in cloud run deploy
- fix: update gcp artifact registry naming and debug admin deploy
- fix: move environment input to with block for build-api
- fix: pass environment as input
- fix: add environment to remaining jobs
- fix: apply environment context to jobs
- fix: add environment context to build jobs
- fix: restore environment context and cleanup debug steps
- fix: remove environment from configuration job
- fix: add credential fallback to configuration job
- fix: credentials fallback and environment context
- fix: add environment context to configuration job for secrets access
- fix: remove invalid failure() call in debug job
- Fix: correct CP/ASG naming in cleanup script
- fix: add GCP WIF secrets to 01-provision-infra workflow_call
- fix: extend cloudwatch log cleanup patterns
- fix: Add workflow_call trigger to allow reuse
- fix: use GITHUB_WORKSPACE for pre-apply script path

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively.

### Added
- Added `.agents/fixtures` to `/checkengines` sweep validations.
- Enhanced `/.agents/scripts/run_sweep.py` with Python harnesses for deterministic validation.
- Improved agent test execution logic to fail-fast on missing test harnesses.
- Updated `macro_flow_checkengines.mermaid` and `macro_flow_allstop.mermaid` visualizations.

### Changed
- Hardened agent workflows by moving logic from shell scripts to Python assertions.
- Upgraded `/checkengines` module validation output formatting.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-16

### Added

- **Deep CI/CD Maintenance Command (`13-deep-cicd-maintenance.md`)**: Added a new master agent workflow that actively analyzes CI/CD definitions and forces documentation, AI prompts, and agent workflows to match reality perfectly, including a deep timestamp synchronization across all 3 repositories.

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Checkengines Sweep**: Updated Engine 4 to validate GitHub Actions uses references are pinned to the latest release tag. Ignored cross-repo workflow orphans, excluded living docs from hygiene check, and focused stress test freshness exclusively on mini runs.
- **AI Context**: Maintained agent workflows sweep 2026-03-16.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-14

### Fixed

- **GCP Workload Identity Federation (WIF)**: Added `token_format: 'access_token'` to `google-github-actions/auth@v3` steps and stopped exporting the credentials file to Terraform to prevent `iam.serviceAccounts.getAccessToken` permission denied errors when initializing the GCS backend.
- **GCP Auth Propagation**: Added and propagated `wif_audience` to auth steps in Pages deploys and stress tests. Added missing GCP secrets to `deploy-app` in the reusable deployment workflows.
- **GCP Artifact Registry**: Updated workflows to use `docker/login-action` for Artifact Registry authentication instead of `gcloud auth configure-docker`.
- **GCP Admin Build**: Removed the unused `build-admin` job from `02-deploy-gcp.yml` to prevent artifact upload pipeline conflicts.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-12

### Fixed

- **Ops Workflows (`reusable-terraform.yml`)**: Added conditional logic to skip the Sharp Lambda@Edge build and VPC Integrity Check steps during Terraform destroy operations to accelerate teardowns.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-04
- Standardize GitHub Action workflow UI names to append Cloud Provider (AWS, Azure, GCP).

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Monolith Decomposition (Phase 1-4)**: Split `02-deploy-app.yml` into `deploy-aws-site.yml`, `deploy-gcp-site.yml`, and `deploy-azure-site.yml`.
- **Ops Utility Decomposition**: Split `99-ops-utility.yml` into explicit domain workflows (`reusable-terraform-operations.yml`, `reusable-cleanup-utilities.yml`, `reusable-security-operations.yml`, `reusable-data-operations.yml`).
- **Stress Test Orchestration**: Refactored `stress-test.yml` into a reusable router calling `stress-test-aws.yml`, `stress-test-gcp.yml`, and `stress-test-azure.yml`.
- fix: Resolving massive JSON schema parser string coercion bugs, workflow dependency deadlocks, and GitHub Actions step max limits.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-03-03
- Standardize GitHub Action workflow UI names to append Cloud Provider (AWS, Azure, GCP).

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- docs: end-of-day governance sync and AI Context updates

## [v1.5.2] - 2026-03-01

### Added

- **`cleanup-orphaned-buckets` ops action** (`99-ops-utility.yml`): New action to find and force-delete orphaned S3 buckets matching the project prefix (excludes tfstate). Accepts `DRY_RUN` or `EXECUTE` confirmation.
- **Orphaned Resource Cleanup — Extended** (`99-ops-utility.yml`): Added cleanup steps for orphaned CloudWatch Log Groups, ALB Target Groups, and CloudFront Functions within the `cleanup-orphaned-buckets` action to resolve Terraform `AlreadyExists` conflicts after partial environment destroy.
- **`gh-actions-troubleshooter` Antigravity Skill**: Created global Antigravity skill at `~/.gemini/config/skills/gh-actions-troubleshooter/` implementing local-first PDCA diagnostic cycle, `get_failed_logs.sh`, `run_local_act.sh` (with `--doctor` check), and curated `ERROR_PATTERNS.txt` reference library.

### Fixed

- **Scope Safety — Cleanup Scripts** (`99-ops-utility.yml`): Corrected resource matching logic in all cleanup steps to strictly use `namespace-client_key-project_key-environment` exact prefix, preventing accidental deletion of resources from other projects sharing the same AWS account (e.g. `blaze-b9-dev-core-*`).
- **CF Function Dedup Crash** (`99-ops-utility.yml`): Fixed `NoSuchFunctionExists` exit-254 crash in the `cleanup-orphaned-buckets` action. `aws cloudfront list-functions` can return duplicate entries — if a function was deleted on loop iteration 1, the second pass would call `describe-function` on a now-gone name and crash. Fixed by: `sort -u` on list output to deduplicate, plus an existence guard (empty ETag check) before attempting `delete-function`.
- **CloudFront Destroy Ordering Workarounds Removed**: With `environment-network` v1.50.15 introducing the `terraform_data.cf_policy_destroy_gate` native fix, all CLI-based workarounds have been removed:
  - `99-ops-utility.yml`: Removed `terraform state rm` for CF cache policies (6 resources) and LB listeners (3 resources) from nuke network `pre_apply_script`.
  - `01-provision-infra.yml`: Removed the `if: destroy && stack == network` guard block with CF policy + LB listener state rm.
  - `reusable-pre-destroy-cleanup.yml`: Removed the 100+ line "🛑 Pre-Destroy CloudFront Distributions & Cache Policies" step (CLI disable/wait/delete logic).
  - Lambda@Edge state rm intentionally retained — valid workaround for AWS's multi-hour replica propagation delay.

## [v1.5.1] - 2026-02-28

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- infra: upgrade core modules to `v1.50.4` (fixes ALB logging `Access Denied` on prefixed paths)
- docs: AI_CONTEXT_GOVERNANCE updated with Section 11 (dual-ALB, VPC CIDRs, module v1.50.3, Lambda@Edge scope)
- docs: REPOSITORY_SYSTEM_PROMPT + PART_03 NotebookLM updated for dual-ALB architecture

## [v1.5.0] - 2026-02-27

### Added

- **DEV-MINI Environment**: New `DEV-MINI` GitHub environment created. Cloudflare Tunnel-only — no ALB, no CloudFront. Secrets propagated via `gh api`. `01-provision-infra.yml`, `02-deploy-app.yml`, and `stress-test.yml` all accept `DEV-MINI` as valid input.
- **Admin SPA Deploy (AWS CloudFront + S3)**: `02-deploy-app.yml` now includes an admin build + S3 sync step followed by CloudFront invalidation for AWS `DEV`/`STAGE`/`PROD` environments. `DEV-MINI` continues to deploy Admin via Cloudflare Pages.
- **Image Resize Verify on DEV**: `stress-test.yml` now runs image resize endpoint verification on the new `DEV` environment (mirrors STAGE).

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Native ECS Blue/Green (active)**: Removed all CodeDeploy references from deployment workflows. API service Blue/Green is now fully managed by ECS natively — no CodeDeploy application, deployment group, or `appspec.yml`. Strategy toggled via `enable_blue_green` (replaces `enable_codedeploy`).
- **DEV mirrors STAGE**: New `dev` Terraform stacks (`dev-app`, `dev-network`) now have full parity with `stage` — ALB, CloudFront, WAF, Image Resize, ECS Fargate. The previous tunnel-only `dev` is now `dev-mini`.

### Removed

- **CodeDeploy**: All `aws deploy create-deployment`, `appspec.yml`, and CodeDeploy IAM role references removed from `02-deploy-app.yml`, `deploy-site.yml`, and `99-ops-utility.yml` nuke pre-cleanup.

---

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-02-25
- Standardize GitHub Action workflow UI names to append Cloud Provider (AWS, Azure, GCP).

### Added

- **Azure Multi-Site Deploy (`reusable-multi-site-deploy.yml`)**: New reusable workflow for deploying individual sites within the 120+ Azure Container Apps fleet.
  - Handles Tier 1 (standard): single revision, instant 100% traffic shift.
  - Handles Tier 2 (premium): multi-revision, staged traffic shift (e.g. 10% → 50% → 100% with 30s delays).
  - Integrates OIDC auth (`azure/login@v2`) and automated ACR token generation.

- **`deploy-site.yml`**: New reusable workflow for multi-site ARM64 deployments.
  - `build` job: Native `ubuntu-24.04-arm` runner — no QEMU, full Graviton build speed. Pushes to ECR with GHA layer caching scoped per `site_key`.
  - `deploy` job: Discovers ECS service by `site_key` suffix dynamically (no hardcoded prefix). Patches container image via `describe-task-definition` + `register-task-definition` + JQ — no task-def JSON files committed to the repo.
  - `rolling` strategy: `aws ecs update-service --force-new-deployment` + `ecs wait services-stable` (standard tier sites).
  - `blue-green` strategy: **Native ECS Blue/Green** — ECS manages the task set swap and traffic shift natively. No CodeDeploy required.
  - Full GitHub Step Summary on every run (build digest, service name, strategy, status).

- **Token Frugality Overhaul**: Major refactor of `/engage`, `/allstop`, `/checkengines`, and `/slash-init-context` to implement targeted context loading and the "Prime Directive" of minimal token usage.
- **Handoff Mechanism**: Added `/slash-handoff` and `/slash-resume` to allow for micro-session isolation and state preservation.

### Fixed

- **Azure Stress Test Parameter (`reusable-terraform-operations.yml`)**: Fixed severe `startup_failure` schema parser crash in Azure stress tests by explicitly providing the required `domain_root` input to `destroy-mongodb` and `final-destroy-mongodb` jobs.
- **Calculate Config Routing (`reusable-calculate-config.yml`)**: Fixed a CRITICAL routing issue where the `multi-site-network`, `multi-site-app`, and `multi-site-cdn` stacks were falling through to the default `${stage}-network` fallback, which injected the wrong TF_DIR and state keys. They now map correctly to `live/multi-site-*` and state `multi-site/*.tfstate`.
- **Nuke CodeDeploy Ordering (`99-ops-utility.yml`)**: Added `pre_apply_script` to Nuke 2/5 App Stack that `state rm`s orphaned CodeDeploy deployment groups before destroy. Fixes `InvalidRoleException` where IAM role is destroyed before the deployment group, and AWS API refuses deletion.

### Added

- **Azure Stress Test Reusable Workflow** (`reusable-azure-stress-test.yml`): New reusable workflow for running end-to-end Azure stress tests. Supports full provision → deploy → verify → optionally destroy lifecycle across Azure Container Apps environments.

### Fixed

- **GCP Resource Importer DNS Cleanup** (`resource-importer`): Added DNS record cleanup steps compatible with Cloudflare provider v4.52.0 to prevent orphaned DNS records on GCP environment teardown.
- **GCP Stress Test Destroy Order**: Swapped CDN and App destroy order to prevent orphaned NEGs (Network Endpoint Groups) when Cloud Run services are destroyed before the CDN/load balancer is cleaned up.
- **Workflow YAML Array Syntax**: Fixed invalid YAML array syntax in `needs` blocks identified during stress test debugging.

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively. - 2026-02-23
- Standardize GitHub Action workflow UI names to append Cloud Provider (AWS, Azure, GCP).

### Added

- **Knowledge Library Docs**: Added new centralized documentation framework (`docs/KNOWLEDGE_LIBRARY.md`) and topic-specific deep dives (`docs/knowledge/smart_fixes/`, etc.)
- **Governance**: Synced `docs/AI_CONTEXT_GOVERNANCE.md` with Public Repository Sanitization rules.
- **`skip_stability_wait` for ECS deploys**: New input on `deploy-ecs-service/action.yml`, `reusable-ecs-deploy.yml`, and `02-deploy-app.yml`. When `true`, skips the `aws-actions/amazon-ecs-deploy-task-definition` stabilisation wait. The stress test now passes `skip_stability_wait: "true"` automatically to prevent 29-minute timeouts when deploying placeholder images to freshly provisioned infrastructure.

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Governance Sync**: Unified AI context documentation across repos.

### Fixed

- **OIDC Connectivity**: Applied `aws-actions/configure-aws-credentials` and `google-github-actions/auth` to `check-stack-exists.yml` to resolve OIDC "Credentials could not be loaded" errors.
- **Stress Test Verify**: 7 fixes to `stress-test.yml` verify logic:
  - Accept 530 for cold start + continue-on-error + 5 retries
  - Changed API check from `/graphql` to `/health`
  - Accept 401 for stage frontend/admin (Cloudflare basic auth)
  - Skip image resize check for stage (`enable_image_resize=false`)
  - Use ECS `services-stable` wait + public URL check instead of TG health
  - Added 90s ECS stabilization wait before verify
- **Nuke Workflow**: Added missing AWS data stack destroy + fix network cascade skip
- **CI Permissions**: Added `actions:write` permission to stress-test workflow

## v1.4.0-workflow-consolidation (2026-02-17)

### Added

- **Ops Utility Expansion**:
  - `cleanup-dns`: New action in `99-ops-utility.yml` to surgically remove DNS records (A, CNAME, TXT) and Cloudflare Pages projects for a specific environment.
  - `nuke-cloudfront`: New action in `99-ops-utility.yml` to forcefully disable and delete stuck CloudFront distributions.
- **Stress Test Validation**:
  - `stress-test.yml`: Validated for use as a reusable workflow via "Wrapper Pattern".

## v1.3.0-tunnel-stability (2026-02-17)

### Added

- **Cloudflare Tunnel Stability**:
  - Implemented "Split Apply" strategy to resolve API consistency issues between Tunnel creation and Configuration.
  - `reusable-terraform.yml`: Added `split_apply`, `split_targets`, and `sleep_seconds` inputs.
  - `reusable-terraform.yml`: Added logic to execute targeted apply -> sleep -> full apply when enabled.
- **Cleanup Hardening**:
  - `99-ops-utility.yml`: Enhanced Nuke Pages cleanup to delete domains before projects (Fixes "Project not found" race condition).
  - `99-ops-utility.yml`: Improved Cloudflare Cleanup logic.

## v1.2.0-multi-cloud-foundation (2026-02-16)

### Added

- **Multi-Cloud Foundation**:
  - `01-provision-infra.yml` & `02-deploy-app.yml` now accept `cloud_provider` input (aws, gcp, azure).
  - `reusable-terraform.yml`: Implemented split backend logic (S3/DynamoDB for AWS, GCS for GCP, Azure Blob for Azure).
  - `calculate-config`: Updated to output provider-specific state bucket formats (e.g., Azure `rg/sa/container`).
- **Hybrid ECS Refinements**:
  - `01-provision-infra.yml`: Added `api_launch_type` and `frontend_launch_type` inputs to support hybrid provisioning.
- **Mandatory Cleanup Protocol**:
  - `reusable-pre-destroy-cleanup.yml`: Added CRITICAL logic to forcefully detach/delete EC2 Capacity Providers and clean up Launch Templates to prevent Terraform destroy hangs.
  - `99-ops-utility.yml`: Integrated `reusable-pre-destroy-cleanup` into the `destroy-resources` job.

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Documentation Synchronization**:
  - Updated `REPOSITORY_SYSTEM_PROMPT.md` to enforce Cleanup Protocols and Hybrid Architecture.
  - Updated `DAILY_DOCUMENTATION_AUDIT.md` and `AI_CONTEXT_GOVERNANCE.md` to include Multi-Cloud and Cleanup checks.
  - Updated `REUSABLE_WORKFLOWS.md`, `WORKFLOW_CATALOG.md`, and `cross-org-secrets.md` to reflect the new capabilities.

## v1.1.0-hybrid-ecs (2026-02-09)

### Added

- **Hybrid ECS Deploy**: `02-deploy-app.yml` now supports `api_launch_type` (FARGATE/EC2) and `api_cpu_architecture` (X86_64/ARM64) inputs for per-service compute selection
- **Reusable ECS Deploy**: `reusable-ecs-deploy.yml` accepts `launch_type` and `cpu_architecture` inputs, passes them to task definition and service update
- **Deploy Action**: `deploy-ecs-service` composite action injects `LAUNCH_TYPE` and `CPU_ARCHITECTURE` into task definition JSON template
- **Task Definition Template**: `api.json` uses `"requiresCompatibilities": ["__LAUNCH_TYPE__"]` and `"cpuArchitecture": "__CPU_ARCHITECTURE__"` placeholders

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Multi-arch Docker Build**: `reusable-docker-build.yml` builds amd64 + arm64 in parallel on native runners, creates multi-arch manifest

## v1.0.0-fargate-stable (2026-02-07)

### Added

- feat: enable Flex tier for DEV environment (auto mode)
- feat: Update MongoDB tier auto-resolution (Dev=Flex, Stage/Prod=M10)
- feat: Enhance Provisioning Summary with deep links and rich details
- feat: enrich provisioning summary and improve cleanup logic
- feat: updates for hybrid pages, system monitor & dynamic namespace
- feat: enable stack-specific import hooks via pre_apply_script
- feat: passthrough enable_image_resize to terraform
- feat: restore provision job and add destroy input
- feat: add app stack support to resource importer
- feat: Execute import recovery script in reusable workflow
- feat: Integrate VPC integrity check into reusable workflow
- feat: add Lambda@Edge error detection to ops summary
- feat: add version-based Sharp layer caching with auto-rebuild
- feat: add CloudFront image resize details to network provisioning summary
- feat: add AI agent auto-learning system
- feat: automate Sharp Lambda Layer build in CI/CD for image resize
- feat: add automatic Cloudflare cache purge after admin deployment
- feat: auto-set Cloudflare Pages production branch in CI/CD
- feat: add automated CHANGELOG generation workflow

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- docs: daily documentation audit 2026-01-21
- docs: add infographic prompts for workflow visualizations
- docs: add NotebookLM prompt template with strict guidelines
- docs: add Slide deck and Infographic as top Studio features
- docs: update NotebookLM guide to focus on Studio features
- docs: add detailed NotebookLM usage guide
- docs: add Google NotebookLM presentation prompts
- docs: make daily audit prompt portable for all users
- docs: add daily documentation audit prompt (00_core)
- docs: comprehensive namespace configuration documentation
- refactor: remove redundant is_paused input from provision workflow
- docs: standardize metadata headers (Owner/Last Updated)
- chore: remove debug steps
- docs: update quick reference for 02-deploy-app and 99-ops-utility
- docs: enforce hybrid naming in system prompt
- docs: init repository system prompt with Mermaid and Hybrid Architecture standards
- docs: finalize removal of hardcoded examples
- docs: use dynamic namespace placeholders in operation guides
- docs: update catalog with strict 01/99 separation and live metrics
- docs: clarify 01 workflow is for creation only
- docs: update default skip_lambda_destroy value
- docs: explain reason for skip_lambda_destroy checkbox
- docs: skip_lambda_destroy in readme & checklist
- chore: full dump of lock table and fallback delete
- chore: add debug for lock table
- chore: increase terraform timeout to 60m
- docs: add terraform init -upgrade to CHANGELOG
- chore: add .agents/ to .gitignore for security
- docs: clarify DEV uses Cloudflare only (no CloudFront/image resize)
- docs: add comprehensive workflow guides for automation
- docs: update CHANGELOG with admin deployment fixes
- docs: add welcome section for external users

### Fixed

- fix: pass AWS credentials to health-check-script job
- fix: use steps.config.outputs instead of needs.configuration.outputs in Pre Apply Script
- fix: add nuke-destroy-pages to environment destruction
- fix: add image resize bucket to pre-destroy cleanup
- fix: add missing fi to shell script
- fix: remove lingering AWS_SECRET_ACCESS_KEY
- fix: remove lingering AWS_ACCESS_KEY_ID
- fix: remove unused AWS secrets from workflows
- fix: improve cloudflare cleanup to dynamically find ACM records
- fix: remove invalid secrets check in workflow conditional
- fix: add cloudflare record cleanup to nuke process
- fix: add zombie OAC and IAM role cleanup to nuke process
- fix: delete md5 digest for state recovery
- fix: correct yaml syntax for provision job and script
- fix: correct frontend target group naming (fe not frontend)
- fix: add network stack resource imports to prevent state drift
- fix: bash substitution error in Sharp layer output step
- fix: add -upgrade to terraform init to force module refresh
- fix: YAML syntax - use inline timestamp parsing
- fix: CRITICAL - properly parse Terraform lock timestamp from Info JSON
- fix: use sudo for all Docker file operations
- fix: use sudo for cleanup of Docker-created files
- fix: override Lambda Docker image entrypoint for Sharp build
- fix: use full repo path for build-sharp-layer action
- fix: use correct admin build output directory (public instead of dist)

## [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- Added Routine 1 Claude Code routines definitions. 
- Replatformed workflows to native Anthropic API orchestrators. 

- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide.

### [Unreleased]
- chore: deep CI/CD maintenance sync across 4 repositories (2026-06-23)
- feat: add multi-project support to calculate-env-config and pass project parameter through reusable stress test workflows
- chore: end-of-day governance sync — 2026-06-23
- chore(cicd): Deep CI/CD maintenance sync (2026-06-17) - Resolved split-brain tagging and standardized pins.
- Chore: Update AI_CONTEXT_GOVERNANCE.md Last Updated to 2026-06-17.
### Changed
- **docs(ai)**: Abstracted `blaze-template-deploy` references into generic "Tenant Implementation Repo" terminology across `CLAUDE.md` to cleanly support multiple downstream tenants (e.g., `shopware-km`).


### Added
- **docs(ai)**: Security Context Split for AWS Profiles. Open repos now dynamically instruct the AI to reference the private tenant `CLAUDE.md` to prevent credential hardcoding.


### Added
- **docs(plan-154)**: `CLAUDE.md` root definitions. Consolidated AI context, naming conventions, and constraints directly into the repo root.
- **chore(ai)**: Formalised 5-Role Sub-Agent mental model (PM, Designer, Engineer, QA, SRE). Injected role mappings into all `.agents/workflows/*.md` files.


### Agent — 2026-05-13 — Client Governance Workflows

- No code changes to blaze-actions today.
- Client seeding work in `KELSEYMedia/shopware-km` relies on `blaze-actions` public reusable workflows — no changes required.

- **Docs**: Deep ECS Fargate Governance Sweep — modernized all `.agents/` workflows, persona instructions, and audit files to strictly mandate ECS Fargate boundaries and purged legacy Elastic Beanstalk context.
### Added
- Added `enable_tunnel`, `enable_vpc_peering`, and Azure specific inputs to `01-provision-infra.yml`.
- Added `frontend_launch_type`, `frontend_cpu_architecture`, and Azure specific inputs to `02-deploy-app.yml`.

### Fixed
- Fixed missing third-party secrets to teardown and provision steps.
- Fixed teardown post-destroy ECS wait to strictly filter by resource prefix.
- Fixed teardown to ensure ECS cluster and ASG cleanup are strictly scoped to resource prefix to prevent cross-project impact.
- Fixed V2 tag schema usage for target group and cloudfront cleanup scripts.
- Passed `MONGODB_ATLAS_PROJECT_ID` to ensure reuse of a single MongoDB Atlas project.


### Added
- feat(workflow): Introduced `WORKERS_JSON` extraction inside `calculate-config`, bridging project environment mapping strictly to backend multi-tenant deployment actions.
- feat(docs): Executed deep validation mapping via `/13-deep-cicd-maintenance`, establishing Dual-Engine capabilities documentation and bumping timestamps system-wide. - 2026-04-16
#### Added
- Synchronized internal AI behavioral mapping across all .agent workflows and contexts to enforce the SCALED Multi-Tenant V2 operational definitions.
- Replicated updated .cursorrules and docs/AI_CONTEXT_GOVERNANCE.md across all three repositories.


### Changed (2026-04-15)
- fix: resolve `amazon-ecr-login` action constraint resolving to v2.1.54
- feat: bypass destructive ECS capacity provider reconciliation by default


- **Automation**: Patched `90-daily-health-check.yml` to load `trivy-action@master` (resolving syntax crash), universally silence Node 20 deprecation tracks, and strictly sandbox Github `${{ }}` outputs via `env:` variables to block Bash 127 panics.
- **Terraform Engine**: Stripped out fictitious `1.14.7` minimum Terraform bounds across `.yml` arguments globally, returning stability to `1.9.0` initialization sequences.
- **Tags**: Slid proxy engine tags `v1.4.14`, `v1.4.19`, and `v1.4.20` gracefully onto `main` HEAD to bypass Github's global immutable execution cache natively.
- Standardize GitHub Action workflow UI names to append Cloud Provider (AWS, Azure, GCP).

### Added

- **Hybrid ECS Support**: `calculate-config` now recognizes `account-settings` stack for ENI Trunking / Container Insights
  - New stack option in `01-provision-infra.yml`: `account-settings`
  - Maps to `.github/aws/infra/live/account-settings` directory
  - Required safety check: `deploy_infra` must be true

### 🚨 Breaking Changes

#### Namespace Hardcoding Removed - Dynamic Namespace Support

**Date:** 2026-01-20  
**Impact:** Resource naming now uses configurable namespace

All workflows now use dynamic `${{ needs.calculate-config.outputs.namespace }}` instead of hardcoded `"blaze"`. This enables:

- Multi-tenancy support
- Organizational isolation
- Custom resource naming prefixes
- Testing with different namespaces

**Resource Naming Pattern (Updated):**

```
${namespace}-${client_key}-${project_key}-${stage_key}-${resource}
```

**Files Changed:**

- `.github/workflows/00_setup_environment.yml` - S3 backend buckets & ECR repository naming
- `.github/workflows/02-deploy-app.yml` - ECS cluster name in deployment summary
- `.github/workflows/reusable-pre-destroy-cleanup.yml` - Resource cleanup with namespace extraction

**Default Behavior:**  
Namespace defaults to `"blaze"` for backward compatibility. Existing deployments are unaffected unless you explicitly change the namespace configuration.

**Migration Guide:**

To maintain existing resources (recommended for production):

```json
// vars/blaze-env.json
{
  "common": {
    "NAMESPACE": "blaze" // Explicitly set to current default
  }
}
```

To use a custom namespace (requires environment rebuild):

1. Export data from existing environment
2. Run nuke workflow to destroy resources
3. Update `NAMESPACE` in `vars/blaze-env.json` or `vars/${PROJECT_KEY}/blaze-env.json`
4. Re-provision infrastructure with `00_setup_environment.yml`
5. Restore data

> **⚠️ Warning:** Changing namespace for an existing environment requires complete rebuild. All AWS resources will be recreated with new names.

**Resources Affected:**

- S3 Buckets: `${client}-${stage}-${namespace}-tfstate`
- ECR Repositories: `${namespace}-${project}-web/*`
- ECS Clusters: `${namespace}-${client}-${project}-${stage}-cluster`
- IAM Roles: `${namespace}-${client}-${project}-${stage}-*-role`
- Lambda Functions: `${namespace}-${client}-${project}-${stage}-*`
- CloudFront OAC: `${namespace}-${client}-${project}-${stage}-cdn-oac`

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **reusable-terraform.yml**: Added `-upgrade` flag to `terraform init` (commit: 9e2e469)
  - Forces fresh module downloads from git refs
  - Prevents cached module issues when module source refs are updated
  - Ensures latest module versions are always used
  - Critical for consuming consuming updated modules from `blaze-terraform-infra-core`

### Added

- **Provisioning Summary**: `01-provision-infra.yml` now generates a detailed infrastructure summary (ALB DNS, ECS Cluster, IAM Role).
  - Uses new outputs from `reusable-terraform.yml`.
- **Policy Deletion**: `reusable-pre-destroy-cleanup` now supports deleting IAM policies by ARN prefix.

### Fixed

- Terraform module caching issues that prevented updated modules from being used

### Added

- **ECR Orphan Import**: New composite action `actions/ecr-orphan-import`
  - Automatically detects ECR repositories that exist in AWS but are missing from Terraform state.
  - Generates `terraform import` blocks to facilitate state reconciliation.
  - Critical for adopting pre-existing ECR repositories into IaC management.

---

## v1.4.0 (2026-01-11)

### Added

**Cloudflare Pages Lifecycle Management**:

- **`cleanup-cloudflare-deployments`**: New action in `99-ops-utility.yml` to clean up old Cloudflare Pages deployments
  - Dual retention policy: by count (default: keep 5) OR age (default: 30 days)
  - Dry-run mode enabled by default for safety
  - Smart filtering keeps latest deployments and recent ones
  - Reduces storage costs and deployment clutter
- **`destroy-cloudflare-pages-bulk`**: New action for pattern-based bulk deletion of Pages projects
  - Pattern matching using shell globs (e.g., `blaze-*-test*-admin`)
  - Safety limit: maximum 10 projects per run
  - Requires special `BULK_DESTROY` confirmation to prevent accidents
  - Dry-run support for preview before deletion
  - Useful for cleaning up test/feature branch projects

**New Workflow Inputs**:

- `retention_count`: Number of deployments to keep (default: 5)
- `retention_days`: Delete deployments older than N days (default: 30)
- `dry_run`: Preview mode without making changes (default: true)
- `bulk_pattern`: Project name pattern for bulk operations

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

**Enhanced Cloudflare Pages Destruction**:

- **Dynamic Configuration**: Replaced hardcoded `"blaze"` and `"thisisblaze"` with configuration outputs
  - Now uses `needs.configuration.outputs.namespace` and `needs.configuration.outputs.project_key`
  - Ensures naming consistency with creation logic in `02-deploy-app.yml`
  - Improves reusability across different projects

- **Enhanced Error Handling**: Added comprehensive HTTP status code handling
  - **HTTP 403 (Forbidden)**: Clear permission error messages with actionable advice
  - **HTTP 429 (Rate Limit)**: Automatic retry with exponential backoff (3 attempts: 2s → 4s → 8s)
  - **HTTP 404 (Not Found)**: Graceful handling for already-deleted projects
  - Improved debugging with detailed error context

### Security

**Safety Features**:

- All destructive Cloudflare operations default to dry-run mode
- Bulk operations require special `BULK_DESTROY` confirmation vs standard `DESTROY`
- Maximum 10 projects per bulk deletion to prevent accidental mass deletion
- Rate limiting protection prevents API abuse

## [1.3.3] - 2026-01-11)

### Added

**New Utility Workflows**:

- **`force-unlock.yml`**: Reusable workflow for unlocking Terraform state locks
  - Removes locks from DynamoDB table
  - Cleans up legacy .tflock files from S3
  - 10-minute timeout for billing protection
- **`debug-lock.yml`**: Reusable workflow for inspecting Terraform state locks
  - Displays lock details from DynamoDB
  - Lists all locks in the table
  - 10-minute timeout for billing protection

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

**Timeout Protection Strategy**:

- Implemented proper billing protection across all reusable workflows
- Timeouts now set at the reusable workflow level (not caller level)
- All workflows verified to have appropriate timeout-minutes settings

**Existing Workflows Enhanced**:

- `fix-state-integrity.yml` - Already had 10min timeout
- `fix-cname-conflict.yml` - Already had 10min timeout
- `sync-secrets-from-ssm.yml` - Already had 10min timeouts on sync jobs
- `smart-dashboard.yml` - Verified timeout protection
- `nuke-cloudfront.yml` - Verified timeout protection
- `02-deploy-app.yml` - Multiple jobs with individual timeouts
- `01-provision-infra.yml` - 15min configuration timeout
- `99-ops-utility.yml` - 5-15min timeouts on all jobs
- `90-daily-health-check.yml` - 10min health-check timeout

### Security

**Billing Protection**:

- All workflows now have proper timeout protection
- Prevents runaway billing from hung workflows (default 6h → controlled timeouts)
- Estimated annual savings: $50-200 across all consuming repositories

## v1.2.0 (2026-01-09)

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- **Hardcoding Removal**: Replaced hardcoded "blaze" strings with dynamic `NAMESPACE` input in `calculate-config`.
- **Dynamic Naming**: Cluster and Bucket names now follow `${CLIENT}-${STAGE}-${NAMESPACE}` pattern.
- **Resource Importer**: `import.sh` now accepts explicit `CLUSTER_NAME` and `NAMESPACE` inputs.

## v1.1.0 (2026-01-08)

### Fixed

- **Critical:** Fixed cross-organization secret propagation in all workflows
  - Replaced `secrets: inherit` with explicit secret passing for cross-org compatibility
  - `01-provision-infra.yml`: Added `AWS_ROLE_ARN` to workflow_call secrets, fixed internal secret propagation to reusable-terraform
  - `02-deploy-app.yml`: Added NPM*TOKEN and all ECS runtime secrets (BLAZE_AUTH*_, BLAZE*CONNECTION_STRING, BLAZE_ELASTICSEARCH*_, BLAZE*FILES_S3*\*, etc.)
  - `90-daily-health-check.yml`: Added complete secret lists to drift-check jobs (Cloudflare, MongoDB, EC, ACM)
  - `00_setup_environment.yml`: Fixed git authentication ordering (Configure Git now runs AFTER setup-blaze)
  - Changed Terraform module ref from `main` to `dev` branch in preinit configuration

### Changed
- chore: repository-wide documentation and timestamp synchronization — March 17, 2026

- `01-provision-infra.yml`: Removed `destroy` option - all destroy operations now consolidated in `99-ops-utility.yml`

### Documentation

- Added comprehensive cross-org secret propagation guide
- Documented secret categories (Infrastructure, Build-time, ECS Runtime, Observability)

## v1.0.0 (2026-01-06)

- feat: add workflow validation (a79ca88)
- Initial release of blaze-actions repository
- 24 reusable workflows extracted
- 5 composite actions
