#!/usr/bin/env python3
import os
import re

# Auto-discover repos
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'utils'))
from repo_paths import get_repos

repos = get_repos(__file__)
actions_dir = repos["actions"]

workflows_dir = os.path.join(actions_dir, ".github", "workflows")
catalog_file = os.path.join(actions_dir, "docs", "WORKFLOW_CATALOG.md")

with open(catalog_file, "r") as f:
    content = f.read()

# Remove deleted
if "#### 08-stress-test-suite.yml" in content:
    content = re.sub(r'#### 08-stress-test-suite\.yml.*?(?=---|\Z)', '', content, flags=re.DOTALL)
if "### reusable-calculate-config.yml" in content:
    content = re.sub(r'### reusable-calculate-config\.yml.*?(?=---|\Z)', '', content, flags=re.DOTALL)

with open(catalog_file, "w") as f:
    f.write(content)

print("Catalog structural sync performed.")
