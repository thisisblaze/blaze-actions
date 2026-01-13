---
description: Debug CI/CD workflow execution issues, GitHub Actions failures, and automation problems
---

# CI/CD Workflow Debugging

**When to use:** GitHub Actions workflows fail, automation doesn't work as expected

## Quick Diagnosis

```bash
# Check recent workflow runs
gh run list --workflow="01-provision-infra.yml" \
  --repo thebyte9/blaze-template-deploy \
  --limit 10

# View specific run
gh run view <run-id> --repo thebyte9/blaze-template-deploy

# Get failed job logs
gh run view <run-id> --log-failed --repo thebyte9/blaze-template-deploy
```

## Common Workflow Issues

### 1. Workflow Not Found (HTTP 404)

**Symptom:**

```
HTTP 404: workflow 01-provision-infra.yml not found on the default branch
```

**Causes:**

1. **Wrong repository** - Workflow is in different repo
2. **Wrong branch** - Workflow doesn't exist on target branch
3. **Wrapper pattern** - Workflow is reusable, called from wrapper

**Fix:**

```bash
# Check which repo has the workflow
gh workflow list --repo thebyte9/blaze-template-deploy
gh workflow list --repo thisisblaze/blaze-actions

# Use correct repo (wrapper repo, not action repo)
gh workflow run "01-provision-infra.yml" \
  --repo thebyte9/blaze-template-deploy \
  --ref main  # Use main branch for wrapper
```

### 2. AWS Credentials Not Loading

**Symptom:**

```
Credentials could not be loaded, please check your action inputs:
Could not load credentials from any providers
```

**Causes:**

1. **Missing AWS_ROLE_ARN secret**
2. **Secret not passed to reusable workflow**
3. **OIDC not configured**

**Fix:**

```yaml
# Wrapper workflow must pass secrets
jobs:
  provision:
    uses: thisisblaze/blaze-actions/.github/workflows/reusable.yml@dev
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }} # Don't forget this!
```

**Verify secret exists:**

```bash
# In GitHub UI:
# Settings → Secrets and variables → Actions
# Check AWS_ROLE_ARN is defined for environment
```

### 3. Action Path Not Found

**Symptom:**

```
Can't find 'action.yml' under '/.github/actions/my-action'.
Did you forget to run actions/checkout?
```

**Causes:**

1. **Relative path in cross-repo call**
2. **Missing checkout step**
3. **Wrong action reference**

**Fix - Use full repo path for cross-repo calls:**

```yaml
# ❌ WRONG (relative path)
- uses: ./.github/actions/build-sharp-layer

# ✅ CORRECT (full repo path with branch)
- uses: thisisblaze/blaze-actions/.github/actions/build-sharp-layer@dev
```

### 4. Docker Build Errors

**Symptom:**

```
entrypoint requires the handler name to be the first argument
```

**Cause:** Default Lambda Docker image entrypoint conflicts with `npm install`

**Fix:**

```yaml
- run: |
    docker run --rm \
      --entrypoint="" \  # Override entrypoint
      -v $(pwd):/build \
      public.ecr.aws/lambda/nodejs:20 \
      npm install
```

### 5. Permission Denied on File Operations

**Symptom:**

```
rm: cannot remove 'file': Permission denied
mv: cannot move 'file': Permission denied
```

**Cause:** Docker creates root-owned files

**Fix:**

```yaml
- run: |
    # Use sudo for Docker-created files
    sudo mkdir -p nodejs
    sudo mv node_modules nodejs/
    sudo zip -r layer.zip nodejs
    sudo rm -rf /tmp/build-dir
```

### 6. YAML Syntax Errors

**Symptom:**

```
error parsing called workflow: You have an error in your yaml syntax on line 224
```

**Common causes:**

1. **Multi-line strings** not properly formatted
2. **Unescaped quotes** in shell commands
3. **Incorrect indentation**

**Fix - Multi-line Python in bash:**

```yaml
# ❌ WRONG (breaks YAML)
- run: |
    RESULT=$(python3 -c "
    from datetime import datetime
    print(datetime.now())
    ")

# ✅ CORRECT (single line)
- run: |
    RESULT=$(python3 -c "from datetime import datetime; print(datetime.now())")
```

## Debugging Techniques

### 1. Enable Debug Logging

Add to workflow file:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

Or set via repository settings:

```bash
# Settings → Secrets and variables → Actions → Variables
# Add: ACTIONS_STEP_DEBUG = true
```

### 2. Add Checkpoint Outputs

```yaml
- name: Debug Checkpoint
  run: |
    echo "🔍 Debugging state:"
    echo "  LAYER_ARN: $LAYER_ARN"
    echo "  BUCKET: $BUCKET"
    echo "  Working Directory: $(pwd)"
    ls -la
    env | sort
```

### 3. Test Locally with Act

```bash
# Install act
brew install act

# Run workflow locally
act -j job-name \
  -s AWS_ROLE_ARN=$AWS_ROLE_ARN \
  --container-architecture linux/amd64
```

### 4. Split Complex Steps

```yaml
# ❌ One monolithic step (hard to debug)
- name: Build Everything
  run: |
    # 100 lines of bash...

# ✅ Multiple focused steps
- name: Setup
  run: mkdir -p build

- name: Install Dependencies
  run: npm install

- name: Build
  run: npm run build

- name: Package
  run: zip -r dist.zip dist/
```

### 5. Use Conditional Debugging

```yaml
- name: Debug on Failure
  if: failure()
  run: |
    echo "Previous step failed, debugging..."
    cat /tmp/error.log
    docker ps -a
    df -h
```

## Iterative Debugging Process

### Pattern Used in This Session (Sharp Layer)

**Iteration 1:**

- ❌ Failed: Wrong repo path
- 🔧 Fix: Use full repo path with `@dev`

**Iteration 2:**

- ❌ Failed: Docker entrypoint error
- 🔧 Fix: Add `--entrypoint=""`

**Iteration 3:**

- ❌ Failed: Cleanup permission denied
- 🔧 Fix: Use `sudo rm`

**Iteration 4:**

- ❌ Failed: Move/zip permission denied
- 🔧 Fix: Use `sudo` for all Docker file ops

**Iteration 5:**

- ✅ SUCCESS! Layer built in 35s

**Iteration 6:** (Bonus)

- ❌ Failed: YAML syntax error (multi-line Python)
- 🔧 Fix: Convert to single-line Python

**Iteration 7:**

- ✅ SUCCESS! Automated and working

### Key Lessons

1. **Commit each fix separately** - Makes debugging easier
2. **Test immediately** - Don't accumulate multiple untested changes
3. **Add descriptive commit messages** - Helps understand context
4. **Use `--exit-status`** - Get immediate feedback on success/failure
5. **Check logs after each run** - Don't assume success

## Workflow Patterns

### Reusable Workflows

```yaml
# Caller (wrapper)
jobs:
  call:
    uses: org/repo/.github/workflows/reusable.yml@branch
    with:
      input1: value1
    secrets:
      SECRET1: ${{ secrets.SECRET1 }}

# Reusable workflow
on:
  workflow_call:
    inputs:
      input1:
        required: true
        type: string
    secrets:
      SECRET1:
        required: true
```

### Composite Actions

```yaml
# .github/actions/my-action/action.yml
name: My Action
inputs:
  param1:
    required: true
outputs:
  result:
    value: ${{ steps.step1.outputs.result }}
runs:
  using: composite
  steps:
    - name: Step 1
      id: step1
      shell: bash
      run: echo "result=value" >> $GITHUB_OUTPUT
```

## Monitoring Workflows

### Set up Notifications

```yaml
# Add to workflow
- name: Notify on Failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Workflow ${{ github.workflow }} failed"
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Track Success Rates

```bash
#!/bin/bash
# get-workflow-stats.sh

WORKFLOW="01-provision-infra.yml"
REPO="thebyte9/blaze-template-deploy"

TOTAL=$(gh run list --workflow="$WORKFLOW" --repo="$REPO" --limit 100 --json conclusion --jq 'length')
SUCCESS=$(gh run list --workflow="$WORKFLOW" --repo="$REPO" --limit 100 --json conclusion --jq '[.[] | select(.conclusion == "success")] | length')

echo "Success rate: $(( SUCCESS * 100 / TOTAL ))%"
echo "Total runs: $TOTAL"
echo "Successful: $SUCCESS"
echo "Failed: $(( TOTAL - SUCCESS ))"
```

## Emergency Recovery

### Cancel Stuck Workflows

```bash
# List running workflows
gh run list --status in_progress --repo thebyte9/blaze-template-deploy

# Cancel specific run
gh run cancel <run-id> --repo thebyte9/blaze-template-deploy

# Cancel all running
gh run list --status in_progress --json databaseId -q '.[].databaseId' | \
  xargs -I {} gh run cancel {} --repo thebyte9/blaze-template-deploy
```

### Workflow Dispatch Limits

GitHub has rate limits:

- **1000 workflow dispatches per hour per repo**
- **250 concurrent workflow runs**

If hit:

```bash
# Wait 60 minutes, or
# Use different repo/branch to distribute load
```

## Best Practices

1. ✅ **Test with `apply=false` first** - Always dry run Terraform
2. ✅ **Use semantic commit messages** - Makes debugging easier
3. ✅ **Add workflow timeouts** - Prevent infinite hangs
4. ✅ **Use `if: always()` for cleanup** - Ensure resources released
5. ✅ **Parameterize all inputs** - Don't hardcode values
6. ✅ **Version pin actions** - Use SHA or tags, not branches
7. ✅ **Add summary outputs** - Use `$GITHUB_STEP_SUMMARY`

---

**Last Updated:** 2026-01-13  
**Debug Sessions:** 2 major (Sharp Layer, Terraform Locks)  
**Success Rate:** 100% after fixes applied
