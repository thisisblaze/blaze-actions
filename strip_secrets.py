import os
import re

files_to_process = [
    "99-ops-aws.yml",
    "99-ops-azure.yml",
    "99-ops-cloudflare.yml",
    "99-ops-gcp.yml",
    "99-ops-nuke.yml",
    "99-ops-terraform.yml",
    "99-ops-utility.yml"
]

base_dir = "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-actions/.github/workflows"

# Regex to match the secrets block inside workflow_call.
# It matches the TODO comments, the `secrets:` key, and all its indented children.
# We look for the start of `    # TODO: Refactor to use secrets: inherit pattern like 01-provision-infra.yml`
# and stop when we see `permissions:` which is the next root-level key.
pattern = re.compile(r"(\s+# TODO: Refactor to use secrets: inherit pattern.*?\n)\s+secrets:\n(?:\s+[A-Za-z0-9_]+:\n\s+required: (?:true|false)\n)+", re.DOTALL)

for filename in files_to_process:
    filepath = os.path.join(base_dir, filename)
    if not os.path.exists(filepath):
        print(f"Skipping {filename}, not found.")
        continue
        
    with open(filepath, "r") as f:
        content = f.read()
        
    new_content = pattern.sub("", content)
    
    if new_content != content:
        with open(filepath, "w") as f:
            f.write(new_content)
        print(f"Successfully stripped secrets from {filename}")
    else:
        print(f"No match found in {filename}")
