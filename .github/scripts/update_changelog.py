#!/usr/bin/env python3
import os

# Auto-discover repos
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'utils'))
from repo_paths import get_all_repo_list

repos = get_all_repo_list(__file__)

changelog_entry = """## [Unreleased]

### Changed
- chore: execute `/13-deep-cicd-maintenance` sync — resolved Git blocker states, audited and synchronized WORKFLOW_CATALOG and REUSABLE_WORKFLOWS, updated Agent deployment triggers to target `01c-provision-app-infra.yml`, and aligned timestamps across repositories.

"""

for repo in repos:
    changelog_path = os.path.join(repo, "CHANGELOG.md")
    if os.path.exists(changelog_path):
        with open(changelog_path, 'r') as f:
            content = f.read()
        
        # Determine where to insert. We can replace '## [Unreleased]' if it exists, or prepend if not.
        if "## [Unreleased]" in content:
            # Just add our log under the first ## [Unreleased]
            parts = content.split("## [Unreleased]\n", 1)
            new_content = parts[0] + changelog_entry + parts[1]
        else:
            new_content = changelog_entry + content
            
        with open(changelog_path, 'w') as f:
            f.write(new_content)
            
print("Changelogs updated.")
