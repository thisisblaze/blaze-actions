#!/usr/bin/env python3
import os
import re

# Auto-discover repos
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'utils'))
from repo_paths import get_all_repo_list

directories = get_all_repo_list(__file__)

date_str = "April 18, 2026"
iso_date = "2026-04-18"

count = 0
for d in directories:
    for root, dirs, files in os.walk(d):
        if ".git" in dirs:
            dirs.remove(".git")
        if "node_modules" in dirs:
            dirs.remove("node_modules")
            
        for f in files:
            if f.endswith(".md"):
                path = os.path.join(root, f)
                with open(path, "r", encoding="utf-8") as file:
                    try:
                        content = file.read()
                    except UnicodeDecodeError:
                        continue
                        
                new_content = re.sub(r'Last Updated: \*\*.*?\*\*', f'Last Updated: **{date_str}**', content)
                new_content = new_content.replace("Date: April 17, 2026", f"Date: {date_str}")
                new_content = new_content.replace("Last Updated: April 17, 2026", f"Last Updated: {date_str}")
                
                if new_content != content:
                    with open(path, "w", encoding="utf-8") as file:
                        file.write(new_content)
                    count += 1
                    
print(f"Timestamp sync completed! Updated {count} files.")
