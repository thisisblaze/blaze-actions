import os
import hashlib

def get_hash(path):
    if not os.path.exists(path): return None
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()

# Intentional divergence allowlist.
# Files listed here are allowed to differ across repos because they contain
# private-repo-only features (e.g. blaze-conductor MCP integration) that
# MUST NOT be added to the public blaze-actions repo per ADR-007 / 13-deep-cicd-maintenance.
# Format: "filename": "reason"
INTENTIONAL_DIVERGENCE = {
    "90-daily-health-check.yml": (
        "blaze-template-deploy extends this workflow with the 'mcp-healing-agent' job "
        "(blaze-conductor MCP, ANTHROPIC_API_KEY). This job must never exist in the public "
        "blaze-actions repo. Divergence is expected and correct. See ADR-017."
    ),
}

def run(repos):
    issues = 0
    # 1. Check CHANGELOG exists
    for name, path in repos.items():
        if not os.path.exists(os.path.join(path, "CHANGELOG.md")):
            print(f"🔴 [Engine 8] {name} repo is missing a CHANGELOG.md")
            issues += 1

    # 2. Parity check for daily health check workflow
    template = "90-daily-health-check.yml"

    # Skip parity check for intentionally divergent files
    if template in INTENTIONAL_DIVERGENCE:
        print(f"✅  [Engine 8] '{template}' — intentional divergence (ADR-017: mcp-healing-agent is private-only). Skipped.")
        return issues

    deploy_hc = os.path.join(repos.get('deploy', ''), ".github", "workflows", template)
    actions_hc = os.path.join(repos.get('actions', ''), ".github", "workflows", template)
    infra_hc = os.path.join(repos.get('infra', ''), ".github", "workflows", template)
    conductor_hc = os.path.join(repos.get('conductor', ''), ".github", "workflows", template)

    hashes = {}
    if os.path.exists(deploy_hc): hashes['deploy'] = get_hash(deploy_hc)
    if os.path.exists(actions_hc): hashes['actions'] = get_hash(actions_hc)
    if os.path.exists(infra_hc): hashes['infra'] = get_hash(infra_hc)
    if os.path.exists(conductor_hc): hashes['conductor'] = get_hash(conductor_hc)

    unique_hashes = set(h for h in hashes.values() if h)

    if len(unique_hashes) > 1:
        print(f"🔴 [Engine 8] Workflow parity failed. '{template}' differs structurally across repositories.")
        issues += 1
    elif len(hashes) == 4 and len(unique_hashes) == 1:
        print(f"✅  [Engine 8] Core workflows ('{template}') are perfectly identical across all 4 repos.")
    else:
        print(f"⚠️  [Engine 8] Could not find '{template}' in all 4 repos to verify parity.")

    return issues
