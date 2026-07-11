import os
import re
import subprocess


def _parse_semver(tag):
    """Parse a vX.Y.Z tag into a sortable tuple. Returns (0,0,0) for unrecognised."""
    m = re.match(r'^v?(\d+)\.(\d+)\.?(\d*)', str(tag))
    if m:
        return tuple(int(x) if x else 0 for x in m.groups())
    return (0, 0, 0)


def _semver_lt(a, b):
    """True when semver a < semver b."""
    return _parse_semver(a) < _parse_semver(b)


def get_latest_release(repo_name):
    try:
        # Use gh cli to get the latest release tag
        result = subprocess.run(
            ['gh', 'release', 'view', '--repo', repo_name, '--json', 'tagName', '-q', '.tagName'],
            capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except Exception:
        return None


# Matches BOTH source URL formats used in live stacks:
#   "github.com/org/repo//path?ref=vX.Y.Z"      ← standard Terraform GitHub source
#   "git::https://github.com/org/repo.git//path?ref=vX.Y.Z"  ← git:: explicit
_TF_REF_PATTERN = re.compile(
    r'source\s*=\s*"'
    r'(?:git::https://github\.com/|github\.com/)'
    r'thisisblaze/blaze-terraform-infra-core'
    r'(?:\.git)?//.*?\?ref=([^\s"]+)"'
)


# Engine 4 validates module pins of *deployed, active* infrastructure only.
# AWS is the sole active cloud today; azure/gcp live stacks are intentionally
# frozen at an older infra-core pin (v2.11.12) and must NOT fail the diagnostic
# until those clouds are reactivated and re-validated (see the azure/gcp
# infra-core parity thread). '_templates' holds pod scaffolding (generator
# input for new stacks), not deployed state, so it is out of scope here too.
# To re-activate a cloud, drop it from _INACTIVE_CLOUD_DIRS.
_INACTIVE_CLOUD_DIRS = {'azure', 'gcp'}
_NON_DEPLOYED_DIRS = {'_templates'}
_PRUNE_DIRS = {'.terraform', 'node_modules', '.git', '_shared'} | _INACTIVE_CLOUD_DIRS | _NON_DEPLOYED_DIRS


def run(repos):
    issues = 0
    actions_tags = set()
    terraform_tags = set()

    deploy_path = repos.get('deploy')
    actions_path = repos.get('actions')

    # Fetch remote latest tags
    latest_actions_tag = get_latest_release('thisisblaze/blaze-actions')
    latest_infra_tag = get_latest_release('thisisblaze/blaze-terraform-infra-core')

    # ── 1. Parse blaze-actions workflow pins used by deploy ────────────────────
    if deploy_path:
        workflows_dir = os.path.join(deploy_path, ".github", "workflows")
        if os.path.exists(workflows_dir):
            for file in os.listdir(workflows_dir):
                if file.endswith(".yml") or file.endswith(".yaml"):
                    with open(os.path.join(workflows_dir, file), 'r') as f:
                        for line in f:
                            # Skip FREEZE-annotated pins — these are intentional frozen versions
                            # (e.g. v2.1.74 in 90-daily-health-check.yml is a chaos-test anti-loop pin)
                            if "FREEZE" in line:
                                continue
                            matches = re.findall(
                                r'uses:\s*thisisblaze/blaze-actions/\.github/workflows/.*?@([^\s]+)',
                                line
                            )
                            actions_tags.update(matches)
                            # also catch composite actions
                            matches_actions = re.findall(
                                r'uses:\s*thisisblaze/blaze-actions/\.github/actions/.*?@([^\s]+)',
                                line
                            )
                            actions_tags.update(matches_actions)

    if not actions_tags:
        print("⚠️  [Engine 4] No github actions tags found to check.")
    else:
        if len(actions_tags) > 1:
            print(f"🔴 [Engine 4] Split-brain github actions tags detected: {sorted(actions_tags, key=_parse_semver)}")
            issues += 1
        else:
            used_tag = list(actions_tags)[0]
            if latest_actions_tag and _semver_lt(used_tag, latest_actions_tag):
                print(
                    f"🔴 [Engine 4] Github actions tags cohesive but OUTDATED! "
                    f"Uses '{used_tag}', but latest is '{latest_actions_tag}'"
                )
                issues += 1
            else:
                msg = "✅  [Engine 4] Github actions tags fully cohesive"
                if latest_actions_tag:
                    msg += f" and natively current: {used_tag}"
                else:
                    msg += f": {used_tag} (could not verify remote)"
                print(msg)

    # ── 2. Parse terraform module source refs ──────────────────────────────────
    # Only scan deploy_path's .github/ for Terraform module refs.
    # blaze-actions is a GitHub Actions hub — it contains NO Terraform live stacks.
    # Scanning actions_path leads to false positives from workspace mirror directories.
    tf_paths = []
    if deploy_path:
        github_subdir = os.path.join(deploy_path, ".github")
        if os.path.isdir(github_subdir):
            tf_paths.append(github_subdir)


    for path in tf_paths:
        if not path:
            continue
        for root, dirs, files in os.walk(path, followlinks=False):
            # Prune heavy dirs + scope to deployed active infra (see _PRUNE_DIRS)
            dirs[:] = [d for d in dirs if d not in _PRUNE_DIRS]
            for file in files:
                if file.endswith(".tf"):
                    with open(os.path.join(root, file), 'r') as f:
                        content = f.read()
                        matches = _TF_REF_PATTERN.findall(content)
                        terraform_tags.update(matches)

    if not terraform_tags:
        print("⚠️  [Engine 4] No terraform tags found to check.")
    else:
        if len(terraform_tags) > 1:
            print(
                f"🔴 [Engine 4] Split-brain terraform module tags detected: "
                f"{sorted(terraform_tags, key=_parse_semver)}"
            )
            issues += 1
        else:
            used_tag = list(terraform_tags)[0]
            if latest_infra_tag and _semver_lt(used_tag, latest_infra_tag):
                print(
                    f"🔴 [Engine 4] Terraform modules cohesive but OUTDATED! "
                    f"Uses '{used_tag}', but latest is '{latest_infra_tag}'"
                )
                issues += 1
            else:
                msg = "✅  [Engine 4] Terraform modules fully cohesive"
                if latest_infra_tag:
                    msg += f" and natively current: {used_tag}"
                else:
                    msg += f": {used_tag} (could not verify remote)"
                print(msg)

    return issues
