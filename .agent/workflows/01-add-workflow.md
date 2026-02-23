---
description: Add a new GitHub Actions workflow to blaze-actions
---

# Add New Workflow

Use this workflow when adding a new workflow or composite action.

## Step 1: Determine Type

**Reusable Workflow** (.github/workflows/):

- Can be called by other workflows
- Use for repeatable processes
- Must have `workflow_call` trigger

**Standalone Workflow** (.github/workflows/):

- Runs on its own (workflow_dispatch, push, schedule)
- Project-specific automation

**Composite Action** (.github/actions/):

- Reusable set of steps
- Can be used in any workflow
- More flexible than reusable workflows

## Adding Reusable Workflow

**Step 1**: Create file

```bash
vim .github/workflows/reusable-<name>.yml
```

**Step 2**: Add workflow structure

```yaml
name: <Name>

on:
  workflow_call:
    inputs:
      environment:
        description: "Environment"
        required: true
        type: string
      # ... other inputs
    secrets:
      AWS_ROLE_ARN:
        required: true
      # ... other secrets

jobs:
  <job-name>:
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - uses: actions/checkout@<SHA> # Always SHA-pin!

      - name: Do something
        run: echo "Process"
```

**Step 3**: Test locally (syntax)

```bash
# Install act (if not installed)
# brew install act

# Test workflow
act workflow_call
```

**Step 4**: Update README.md
Add to workflow catalog

**Step 5**: Commit

```bash
git checkout -b feat/add-<name>-workflow
git add .github/workflows/reusable-<name>.yml
git commit -m "feat: add <name> reusable workflow"
git push origin feat/add-<name>-workflow
```

## Adding Composite Action

**Step 1**: Create directory

```bash
mkdir -p .github/actions/<action-name>
cd .github/actions/<action-name>
```

**Step 2**: Create action.yml

```yaml
name: "<Action Name>"
description: "<Description>"

inputs:
  parameter:
    description: "<Description>"
    required: true

outputs:
  result:
    description: "<Description>"
    value: ${{ steps.<step-id>.outputs.result }}

runs:
  using: "composite"
  steps:
    - name: Do something
      id: <step-id>
      shell: bash
      run: |
        echo "result=value" >> $GITHUB_OUTPUT
```

**Step 3**: Create README.md

```markdown
# <Action Name>

<Description>

## Usage

\`\`\`yaml

- uses: thebyte9/blaze-actions/.github/actions/<action-name>@v1
  with:
  parameter: value
  \`\`\`

## Inputs

| Name      | Description | Required |
| :-------- | :---------- | :------- |
| parameter | Description | yes      |

## Outputs

| Name   | Description |
| :----- | :---------- |
| result | Description |
```

**Step 4**: Test

```yaml
# Create test workflow
cat > .github/workflows/test-action-example.yaml << 'EOF'
name: Test Action

on: workflow_dispatch

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA>

      - uses: ./.github/actions/<action-name>
        with:
          parameter: test-value
EOF
```

**Step 5**: Commit

```bash
git add .github/actions/<action-name>/
git commit -m "feat: add <action-name> composite action"
```

## Checklist

- [ ] Correct location (.github/workflows/ or .github/actions/)
- [ ] SHA-pinned GitHub Actions (not @v4, use @SHA)
- [ ] timeout-minutes set on all jobs
- [ ] README.md created (for actions)
- [ ] Catalog updated (README.md)
- [ ] Tested (at least syntax check)
- [ ] Committed with descriptive message

## Best Practices

**SHA Pinning**:

```yaml
# ❌ Bad - mutable tag
- uses: actions/checkout@v4

# ✅ Good - immutable SHA
- uses: actions/checkout@692973e3d937129bcbf40652eb9f2f61becf3332 # v4.1.7
```

**Timeout Protection**:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 30 # Always set!
```

**Documentation**:

- Clear description of inputs/outputs
- Usage example
- When to use this workflow/action

## Notes

- **Always SHA-pin** - Security requirement
- **Always set timeouts** - Billing protection
- **Test before merging** - At least syntax
- **Document well** - Others will use these
- **Keep focused** - One workflow = one purpose
