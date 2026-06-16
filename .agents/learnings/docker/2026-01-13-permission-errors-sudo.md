# Docker Permission Errors with Root-Owned Files

**Auto-captured:** 2026-01-13T10:06:05Z  
**Trigger:** iterative_debugging (4 iterations)  
**Category:** docker  
**Complexity:** 3/10  
**Iterations:** 4

---

## Problem/Error

**Symptom:**

```
rm: cannot remove '/tmp/sharp-layer/node_modules/sharp/lib/index.d.ts': Permission denied
mv: cannot move 'node_modules' to 'nodejs/node_modules': Permission denied
```

**Context:**

- File: `.github/actions/build-sharp-layer/action.yml`
- Workflow: `01-provision-infra.yml`
- Environment: GitHub Actions (ubuntu-latest)

---

## Root Cause

Docker runs as root user and creates root-owned files in mounted volumes. When GitHub Actions runner (non-root user) tries to operate on these files, permission is denied.

**Why it happened:**

1. Docker container runs as root by default
2. Files created in mounted volume inherit root ownership
3. GitHub Actions runner is non-root user
4. Standard shell commands fail on root-owned files

---

## Fix Applied

**Code changes:**

```yaml
# Cleanup step
- run: sudo rm -rf /tmp/sharp-layer

# Build operations
- run: |
    sudo mkdir -p nodejs
    sudo mv node_modules nodejs/
    sudo zip -r sharp-layer.zip nodejs
```

**Files modified:**

- `.github/actions/build-sharp-layer/action.yml`

**Commits:**

- `51b7e92` - "fix: use sudo for cleanup of Docker-created files"
- `bf8eca3` - "fix: use sudo for all Docker file operations"

---

## Prevention

**To avoid this in future:**

1. ✅ **Always use `sudo`** for operations on Docker-created files
2. ✅ **Use `--user $(id -u):$(id -g)`** in docker run (alternative approach)
3. ✅ **Add cleanup in `if: always()`** to ensure resources released

**Pattern to remember:**

```yaml
# When using Docker with volume mounts:
docker run -v $(pwd):/build ...
# Then ALL file operations need sudo:
sudo mv /build/output/ final/
sudo rm -rf /build/
sudo chown -R $(whoami) final/  # Optional: reclaim ownership
```

---

## Related

**Similar issues:**

- Sharp layer build (this issue)
- Any Docker build creating artifacts
- Lambda layer packaging
- Container-based CI/CD workflows

**Will affect:**

- Future Lambda layer builds
- Docker-based build actions
- Any volume-mounted Docker operations

---

## Testing

**Verification:**

```bash
# Trigger workflow
gh workflow run "01-provision-infra.yml" \
  -f environment=STAGE \
  -f stack=network

# Check logs for success
gh run watch <run-id>
```

**Success criteria:**

- ✅ No permission denied errors
- ✅ Cleanup step completes
- ✅ Artifacts created successfully

---

## Metrics

| Metric                | Value          |
| --------------------- | -------------- |
| **Iterations to fix** | 4              |
| **Time to diagnose**  | ~5 minutes     |
| **Time to fix**       | ~10 minutes    |
| **Files changed**     | 1              |
| **Lines changed**     | 6              |
| **Success rate**      | 100% after fix |

---

## AI Agent Notes

**Pattern recognized:** docker-root-permissions

**Confidence in fix:** 100%

**Reusability:** 10/10 (will occur in any Docker build scenario)

**Should create workflow guide:** Yes - Added to `debug-cicd-workflows.md`

---

**Auto-captured by AI Agent**  
**Status:** ✅ Documented, ✅ Fixed, ✅ Preventable
