#!/usr/bin/env python3
import os
import subprocess
import re

def print_refs(title, filepath):
    print(f"=== {title} ===")
    try:
        if not os.path.exists(filepath):
            print(f"  [File not found or not mapped yet]")
            return
        
        count = 0
        with open(filepath, 'r') as f:
            for line in f:
                if 'ref=' in line:
                    # Clean up the output to be identical to grep
                    print(line.strip('\n'))
                    count += 1
                    if count >= 3:
                        break
    except Exception as e:
        print(f"Error reading file: {e}")

def get_latest_tags(repo_path):
    print("=== infra-core latest tag ===")
    try:
        # Get all tags safely
        result = subprocess.run(['git', '-C', repo_path, 'tag'], capture_output=True, text=True, check=True)
        tags = [t.strip() for t in result.stdout.strip().split('\n') if t.strip()]
        
        if not tags:
            print("  [No tags found]")
            return

        # Simple semantic version sort
        def parse_version(tag):
            m = re.match(r'^v?(\d+)\.(\d+)\.?(\d*)', tag)
            if m:
                return tuple(int(x) if x else 0 for x in m.groups())
            return (0, 0, 0)
            
        tags.sort(key=parse_version)
        
        for tag in tags[-3:]:
            print(tag)
    except Exception as e:
        print(f"Error fetching tags: {e}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.abspath(os.path.join(script_dir, "../../../.."))

    # If invoked via symlink, base_dir is the workspace root (has blaze-template-deploy/).
    # If invoked directly from _shared/, fall back to _shared/ parent which has the workspaces.
    deploy_stack = "blaze-template-deploy/.github/aws/infra/live/dev-mini-network/main.tf"
    if not os.path.exists(os.path.join(base_dir, deploy_stack)):
        # Likely running from _shared/ — try one level up, then into the first workspace that has it
        parent = os.path.dirname(base_dir)
        for candidate in ["thebyte9/thebyte9-blaze-template-deploy", "thebyte9/thebyte9-shopware-km", "KELSEYMedia"]:
            test = os.path.join(parent, candidate, deploy_stack)
            if os.path.exists(test):
                base_dir = os.path.join(parent, candidate)
                break

    # Both repos have dev-mini-network — compare these for split-brain detection (Rule 4)
    deploy_path = os.path.join(base_dir, "blaze-template-deploy/.github/aws/infra/live/dev-mini-network/main.tf")
    actions_path = os.path.join(base_dir, "blaze-actions/.github/aws/infra/live/dev-mini-network/main.tf")
    core_path = os.path.join(base_dir, "blaze-terraform-infra-core")

    print_refs("blaze-template-deploy (dev-mini-network)", deploy_path)
    print_refs("blaze-actions (dev-mini-network)", actions_path)
    get_latest_tags(core_path)
