# Session Handoff State

**Date/Time**: 2026-03-18T17:42:12Z

## 1. The Exact Objective

The immediate goal is monitoring the successfully deployed AWS ECS or Cloud Run containers (via `02-deploy-app.yml`) and ensuring that the `api-dev.thisisblaze.uk` GraphQL endpoint is functionally responding after fixing the catastrophic 4-second `startup_failure` AST bug.

## 2. Current Progress & Modified Files

- `scripts/inject_full_secrets.py`: Modified to include all 34 secrets natively (including `BLAZE_ELASTICSEARCH_USERNAME`, `MONGO_INITDB_ROOT_PASSWORD`, etc. which were severely crashing AST parsers).
- `.github/workflows/*.yml` (Global): Completely unified across the board using the python generator to enforce identical `<secret>` inputs universally, bypassing the GitHub AST evaluation drop logic completely. 
- `v1.4.9`: Forced and tagged successfully on `dev`.
- `blaze-template-deploy/docs/image-resize/README.md`: Committed docs for the CloudFront Edge Header strip handling (solving the image resize pipeline bugs).

## 3. Important Context

- **The Big Bug Solved**: GitHub evaluates the full AST schema tree of every `workflow_call` file depth before executing conditionals. Nested files didn't natively have Elasticsearch variables mapped in their schemas, fatally crashing caller templates violently upon trigger.
- **WAF policy**: CloudFront-only (stage/prod). ALBs are internal.
- **NAT policy**: GATEWAY when >5 services, NONE otherwise.
- **Redis**: prod-only. Prod Redis must be on private subnets (not public).

## 4. The Immediate Next Steps

1. Verify that `api-dev.thisisblaze.uk/graphql` successfully connects to MongoDB and initializes following the deployment.
2. Confirm stress test pipeline stability with the newly merged pipelines natively.
