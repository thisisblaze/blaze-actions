# Contributing Guide

Thank you for contributing to blaze-actions!

---

## How to Contribute

### 1. Adding a New Workflow

See [.agent/workflows/01-add-workflow.md](.agent/workflows/01-add-workflow.md) for detailed guide.

**Quick steps**:

1. Create `.github/workflows/<name>.yml`
2. Add `workflow_call` trigger for reusable workflows
3. SHA-pin all GitHub Actions
4. Set `timeout-minutes` on all jobs
5. Update README.md catalog
6. Submit PR

### 2. Adding a Composite Action

**Step 1**: Create directory

```bash
mkdir -p .github/actions/<action-name>
```

**Step 2**: Create `action.yml` and `README.md`

**Step 3**: Submit PR

### 3. Updating Existing Workflow/Action

**Non-Breaking Changes** (PATCH/MINOR):

```bash
git checkout dev
git checkout -b fix/update-workflow-name

# Make changes
# Update CHANGELOG.md
# Test

git commit -m "fix: description"
git push origin fix/update-workflow-name
```

**Breaking Changes** (MAJOR):

- Discuss in issue first
- Provide migration guide
- Update CHANGELOG with BREAKING CHANGE

---

## Code Standards

### GitHub Actions Style

**SHA Pinning** (Required):

```yaml
# ❌ Bad
- uses: actions/checkout@v4

# ✅ Good
- uses: actions/checkout@692973e3d937129bcbf40652eb9f2f61becf3332 # v4.1.7
```

**Timeout Protection** (Required):

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 30 # Always set!
```

**Input Validation**:

```yaml
inputs:
  environment:
    description: "Environment"
    required: true
    type: choice
    options: ["dev", "stage", "prod"]
```

### YAML Formatting

- 2-space indentation
- Comments above complex sections
- Descriptive step names

---

## Testing

### Syntax Validation

```bash
# Install actionlint
brew install actionlint

# Validate workflow
actionlint .github/workflows/<workflow>.yml
```

### Local Testing (Optional)

```bash
# Install act
brew install act

# Test workflow
act workflow_dispatch
```

### Real Testing

Create test workflow that calls your workflow/action:

```yaml
name: Test
on: workflow_dispatch
jobs:
  test:
    uses: ./.github/workflows/your-workflow.yml@dev
    with:
      test: value
```

---

## Pull Request Process

### 1. PR Title Format

```
<type>: <description>

Types:
- feat: New workflow/action
- fix: Bug fix
- docs: Documentation
- refactor: Code refactor
- chore: Maintenance
```

### 2. PR Description

```markdown
## Description

Brief description

## Type of Change

- [ ] New workflow
- [ ] New action
- [ ] Bug fix
- [ ] Breaking change

## Testing

- How was this tested?

## Checklist

- [ ] SHA-pinned actions
- [ ] timeout-minutes set
- [ ] CHANGELOG updated
- [ ] README catalog updated
```

### 3. Review Process

- Maintainer reviews within 2 business days
- Address feedback
- Squash commits before merge
- Squash commits before merge

---

## Release Process (Maintainers Only)

### 1. Update CHANGELOG

```markdown
## [v1.1.0] - 2026-01-07

### Added

- New workflow: `reusable-<name>.yml`

### Changed

- Updated action `<name>` to support X

### Fixed

- Fixed bug in `<workflow>`
```

### 2. Tag Release

```bash
git tag -a v1.1.0 -m "Release v1.1.0

- Added workflow X
- Fixed bug Y"

git push origin v1.1.0
```

## Security Requirements

✅ **SHA Pinning**: All actions must use commit SHAs  
✅ **Timeout Protection**: All jobs must have timeout-minutes  
✅ **Secret Handling**: Use secrets, never hardcode  
✅ **OIDC**: Use OIDC for AWS, not long-lived credentials

---

## Questions?

- Open an issue
- Tag with `question` label

---

## License

By contributing, you agree contributions are licensed under Apache License 2.0.
