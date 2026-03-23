import os
import hashlib

def get_hash(path):
    if not os.path.exists(path): return None
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()

def run(repos):
    issues = 0
    # 1. Check CHANGELOG exists
    for name, path in repos.items():
        if not os.path.exists(os.path.join(path, "CHANGELOG.md")):
            print(f"🔴 [Engine 8] {name} repo is missing a CHANGELOG.md")
            issues += 1

    # 2. Parity check for daily health check workflow
    template = "90-daily-health-check.yml"
    deploy_hc = os.path.join(repos.get('deploy', ''), ".github", "workflows", template)
    actions_hc = os.path.join(repos.get('actions', ''), ".github", "workflows", template)
    infra_hc = os.path.join(repos.get('infra', ''), ".github", "workflows", template)

    hashes = {}
    if os.path.exists(deploy_hc): hashes['deploy'] = get_hash(deploy_hc)
    if os.path.exists(actions_hc): hashes['actions'] = get_hash(actions_hc)
    if os.path.exists(infra_hc): hashes['infra'] = get_hash(infra_hc)

    unique_hashes = set(h for h in hashes.values() if h)
    
    if len(unique_hashes) > 1:
        print(f"🔴 [Engine 8] Workflow parity failed. '{template}' differs structurally across repositories.")
        issues += 1
    elif len(hashes) == 3 and len(unique_hashes) == 1:
        print(f"✅  [Engine 8] Core workflows ('{template}') are perfectly identical across all 3 repos.")
    else:
        print(f"⚠️  [Engine 8] Could not find '{template}' in all 3 repos to verify parity.")
        
    return issues
