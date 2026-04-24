import os
import re

def update_tags(directory, new_tag):
    count = 0
    pattern = re.compile(r'@v2\.1\.\d+')
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.yml') or file.endswith('.yaml'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r') as f:
                        content = f.read()
                    
                    if pattern.search(content):
                        new_content = pattern.sub('@' + new_tag, content)
                        # also replace string defaults in inputs if they were bare v2.1.x
                        new_content = re.sub(r'default: "v2\.1\.\d+"', 'default: "' + new_tag + '"', new_content)
                        new_content = re.sub(r'options: \["v2\.1\.\d+"', 'options: ["' + new_tag + '"', new_content)

                        if content != new_content:
                            with open(path, 'w') as f:
                                f.write(new_content)
                            print(f"Updated {path}")
                            count += 1
                except Exception as e:
                    pass
    print(f"Total files updated: {count}")

update_tags('/Users/marek/Workspace/thisisblaze/blaze-actions/.github', 'v2.1.74')
