# Description

Please include a summary of the change and which issue is fixed.

## Type of Change

- [ ] New Workflow (Multi-Cloud Support Required)
- [ ] New Feature (Hybrid ECS / Cleanup Protocol)
- [ ] Bug Fix
- [ ] Documentation Update
- [ ] Refactor / Maintenance

## Multi-Cloud Compliance

- [ ] Validated on AWS
- [ ] Validated on GCP (if applicable)
- [ ] Validated on Azure (if applicable)
- [ ] Inputs include `cloud_provider` routing logic

## Cleanup Protocol (Mandatory)

**Crucial**: Does this change create infrastructure?
- [ ] **YES**: I have implemented corresponding cleanup logic in `99-ops-utility.yml` or `reusable-pre-destroy-cleanup.yml`.
- [ ] **NO**: This is a pure logic/docs change.

## Testing

- [ ] Unit Tests
- [ ] Manual Verification (Describe below)
- [ ] `check-stack-exists` validation

## Checklist

- [ ] SHA-pinned actions (No `@v1` tags)
- [ ] `timeout-minutes` set on ALL jobs
- [ ] CHANGELOG.md updated
- [ ] README.md / Workflow Catalog updated
- [ ] No hardcoded secrets (use OIDC/GitHub Secrets)
