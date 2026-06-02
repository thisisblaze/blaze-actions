import re
import os

repos = [
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-actions",
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-conductor",
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-terraform-infra-core",
  "/Users/marek/Workspace/00-Google-Antigravity/thebyte9/thebyte9-blaze-template-deploy/blaze-template-deploy"
]

required = ["**/.DS_Store", "scratch/", "*.log", "*.tmp", "*.temp", ".env", ".secrets"]

for r in repos:
    path = r + "/.gitignore"
    try:
        if not os.path.exists(path):
             with open(path, "w") as f:
                  f.write("\n".join(required) + "\n")
             print(f"Created {path}")
             continue
             
        with open(path, "r") as f:
            lines = [l.strip() for l in f.readlines()]
            
        new_lines = []
        for l in lines:
            if l == ".agent/" or l == ".agent" or l == "/.agent/":
                continue # remove agent ignore
            new_lines.append(l)
            
        for req in required:
            if req not in new_lines:
                new_lines.append(req)
                
        new_content = "\n".join(new_lines) + "\n"
        with open(path, "w") as f:
            f.write(new_content)
        print(f"Checked and fixed .gitignore in {r}")
    except Exception as e:
        print(f"Error {r}: {e}")
