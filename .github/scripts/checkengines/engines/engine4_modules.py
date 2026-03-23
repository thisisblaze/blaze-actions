import os
import re

def run(repos):
    issues = 0
    actions_tags = set()
    terraform_tags = set()

    deploy_path = repos.get('deploy')
    actions_path = repos.get('actions')

    # 1. Parse blaze-actions workflows used by deploy
    if deploy_path:
        workflows_dir = os.path.join(deploy_path, ".github", "workflows")
        if os.path.exists(workflows_dir):
            for file in os.listdir(workflows_dir):
                if file.endswith(".yml") or file.endswith(".yaml"):
                    with open(os.path.join(workflows_dir, file), 'r') as f:
                        content = f.read()
                        matches = re.findall(r'uses:\s*thisisblaze/blaze-actions/\.github/workflows/.*?@([^\s]+)', content)
                        actions_tags.update(matches)

    if len(actions_tags) > 1:
        print(f"🔴 [Engine 4] Split-brain github actions tags detected in blaze-template-deploy: {actions_tags}")
        issues += 1
    elif len(actions_tags) == 1:
        print(f"✅  [Engine 4] Github actions tags fully cohesive: {list(actions_tags)[0]}")
    else:
        print(f"⚠️  [Engine 4] No github actions tags found to check.")

    # 2. Parse terraform modules
    tf_paths = [deploy_path, actions_path]
    for path in tf_paths:
        if not path: continue
        for root, dirs, files in os.walk(path):
            if '.terraform' in root: continue
            for file in files:
                if file.endswith(".tf"):
                    with open(os.path.join(root, file), 'r') as f:
                        content = f.read()
                        matches = re.findall(r'source\s*=\s*"git::https://github\.com/thisisblaze/blaze-terraform-infra-core\.git//.*?\?ref=([^\s"]+)"', content)
                        terraform_tags.update(matches)

    if len(terraform_tags) > 1:
        print(f"🔴 [Engine 4] Split-brain terraform module tags detected: {terraform_tags}")
        issues += 1
    elif len(terraform_tags) == 1:
        print(f"✅  [Engine 4] Terraform modules fully cohesive: {list(terraform_tags)[0]}")
    else:
        print(f"⚠️  [Engine 4] No terraform tags found to check.")

    return issues
