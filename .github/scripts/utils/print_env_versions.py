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
    tdeploy_path = "/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.github/aws/infra/live/dev-network/main.tf"
    actions_path = "/Users/marek/Workspace/thisisblaze/blaze-actions/.github/aws/infra/live/dev-network/main.tf"
    core_path = "/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core"
    
    print_refs("blaze-template-deploy", tdeploy_path)
    print_refs("blaze-actions", actions_path)
    get_latest_tags(core_path)
