#!/usr/bin/env python3
import os
import re
from datetime import datetime
import sys

# Auto-discover repos
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '.github', 'scripts', 'utils'))
from repo_paths import get_all_repo_list

def update_timestamps(directories):
    today = datetime.now().strftime("%2026-04-24") # Format to current simulation date
    count = 0
    pattern = re.compile(r'Last Updated:? \d{4}-\d{2}-\d{2}')
    for directory in directories:
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith('.md'):
                    path = os.path.join(root, file)
                    try:
                        with open(path, 'r') as f:
                            content = f.read()
                        
                        if pattern.search(content):
                            new_content = pattern.sub(f'Last Updated: 2026-04-24', content)
                            if content != new_content:
                                with open(path, 'w') as f:
                                    f.write(new_content)
                                print(f"Updated timestamp in {path}")
                                count += 1
                    except Exception as e:
                        pass
    print(f"Total timestamps updated: {count}")

# Build directory list from all repos: docs/ and .agent/ subdirs
all_dirs = []
for repo in get_all_repo_list(__file__):
    for subdir in ['docs', '.agent']:
        d = os.path.join(repo, subdir)
        if os.path.isdir(d):
            all_dirs.append(d)

update_timestamps(all_dirs)
