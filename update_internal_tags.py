import os
import glob
import re

workflow_files = glob.glob('/Users/marek/Workspace/thisisblaze/blaze-actions/.github/workflows/*.yml')
action_files = glob.glob('/Users/marek/Workspace/thisisblaze/blaze-actions/.github/actions/**/*.yml', recursive=True)

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
