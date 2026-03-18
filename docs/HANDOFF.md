# Session Handoff State

## Sprint Board

| Status | Task | Context | Date |
|---|---|---|---|
| ⬜ TODO | Troubleshoot `AccessDenied` on `admin-dev.thisisblaze.uk` via htaccess | Immediate | 2026-03-18 |
| ⏸️ PAUSED | Verify `api-dev.thisisblaze.uk/graphql` MongoDB connection | Previous Session | 2026-03-18 |
| ⏸️ PAUSED | Confirm stress test pipeline stability natively | Previous Session | 2026-03-18 |
| ✅ DONE | Configure Dependabot horizontally across all 3 repos | MacBook Pro | 2026-03-18 |
| ✅ DONE | Mass update 58 action versions to v3.0.0/v6.0.2/v6.3.0 | MacBook Pro | 2026-03-18 |

---

## Session Journal

### Session Handoff — 2026-03-18T17:52:36Z

**Machine/Context**: MacBook Pro — Dependabot and Action Version Bumps

#### 1. The Exact Objective

The immediate goal was to establish automated dependency updates across all three repositories (blaze-actions, blaze-terraform-infra-core, blaze-template-deploy) and mass-update specific actions (`azure/login`, `actions/checkout`, `actions/setup-node`) to unblock the pipeline properly.

#### 2. Current Progress & Modified Files

- `.github/dependabot.yml` created in all 3 repositories.
- `*.yml` / `*.yaml` / `*.sh` action versions updated across 58 files using a Python script.
- Code successfully pushed to the `dev` branches.

#### 3. Important Context

- Action updates have been committed directly to `dev`. Dependabot will take over from here to handle future upgrades.
- New blocker encountered right before handoff: `admin behind htaccess https://admin-dev.thisisblaze.uk/ shows <Error><Code>AccessDenied</Code><Message>Access Denied</Message></Error>` 

#### 4. The Immediate Next Steps

> See Sprint Board task #1 above (Troubleshoot AccessDenied on admin-dev).

---

### Session Handoff — 2026-03-18T17:42:12Z

**Machine/Context**: Previous Session

#### 1. The Exact Objective
The immediate goal is monitoring the successfully deployed AWS ECS or Cloud Run containers (via `02-deploy-app.yml`) and ensuring that the `api-dev.thisisblaze.uk` GraphQL endpoint is functionally responding after fixing the catastrophic 4-second `startup_failure` AST bug.

#### 2. Current Progress & Modified Files
- `scripts/inject_full_secrets.py`: Modified to include all 34 secrets natively.
- `.github/workflows/*.yml` (Global): Completely unified across the board. 
- `v1.4.9`: Forced and tagged successfully on `dev`.
- `blaze-template-deploy/docs/image-resize/README.md`: Committed docs for the CloudFront Edge Header strip handling.

#### 3. Important Context
- **The Big Bug Solved**: GitHub evaluates the full AST schema tree of every `workflow_call` file depth before executing conditionals. Nested files didn't natively have Elasticsearch variables mapped in their schemas, fatally crashing caller templates violently upon trigger.
- **WAF policy**: CloudFront-only (stage/prod). ALBs are internal.
- **NAT policy**: GATEWAY when >5 services, NONE otherwise.
- **Redis**: prod-only. Prod Redis must be on private subnets (not public).

#### 4. The Immediate Next Steps
1. Verify that `api-dev.thisisblaze.uk/graphql` successfully connects to MongoDB and initializes following the deployment.
2. Confirm stress test pipeline stability with the newly merged pipelines natively.
