#!/usr/bin/env python3
import os
import glob
import re
import sys

# Auto-discover repos
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '.github', 'scripts', 'utils'))
from repo_paths import get_repos

repos = get_repos(__file__)
actions_dir = repos["actions"]

workflow_files = glob.glob(os.path.join(actions_dir, '.github', 'workflows', '*.yml'))
action_files = glob.glob(os.path.join(actions_dir, '.github', 'actions', '**', '*.yml'), recursive=True)

all_files = workflow_files + action_files
count = 0
for file in all_files:
    with open(file, 'r') as f:
        content = f.read()
    
    new_content = re.sub(r'@v2\.1\.\d+', '@v2.1.73', content)
    if new_content != content:
        with open(file, 'w') as f:
            f.write(new_content)
        print(f"Updated {file}")
        count += 1
print(f"Total updated: {count}")
