#!/usr/bin/env python3
import os
import re
import shutil
import sys

# Auto-discover repos
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '.github', 'scripts', 'utils'))
from repo_paths import get_all_repo_list, get_repos

REPOS = get_all_repo_list(__file__)

def main():
    repos = get_repos(__file__)
    print("Replacing @dev tags with @v1.4.30 in workflows...")
    for repo in REPOS:
        for root, dirs, files in os.walk(os.path.join(repo, '.github')):
            for file in files:
                if file.endswith('.yml') or file.endswith('.yaml'):
                    p = os.path.join(root, file)
                    with open(p, 'r') as f:
                        c = f.read()

                    pattern = r'(uses:\s*thisisblaze/blaze-actions/(?:\.github/workflows|\.github/actions)/[^@\n]+)@dev'
                    new_c, cnt = re.subn(pattern, r'\1@v1.4.30', c)

                    if cnt > 0:
                        with open(p, 'w') as f:
                            f.write(new_c)
                        print(f"Updated {cnt} occurrence(s) in {p}")

    print("\nSyncing workflow parity (Engine 8)...")
    source = os.path.join(repos["infra"], ".github", "workflows", "90-daily-health-check.yml")
    dest1 = os.path.join(repos["deploy"], ".github", "workflows", "90-daily-health-check.yml")
    dest2 = os.path.join(repos["actions"], ".github", "workflows", "90-daily-health-check.yml")
    
    shutil.copy2(source, dest1)
    print(f"Synced {dest1}")
    shutil.copy2(source, dest2)
    print(f"Synced {dest2}")

if __name__ == '__main__':
    main()
