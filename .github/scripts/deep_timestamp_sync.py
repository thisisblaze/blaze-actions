import os
import re

directories = [
    "/Users/marek/Workspace/thisisblaze/blaze-actions",
    "/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core",
    "/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy"
]

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
