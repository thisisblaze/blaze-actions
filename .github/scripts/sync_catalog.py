import os
import yaml
import re

workflows_dir = "/Users/marek/Workspace/thisisblaze/blaze-actions/.github/workflows"
catalog_file = "/Users/marek/Workspace/thisisblaze/blaze-actions/docs/WORKFLOW_CATALOG.md"

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
