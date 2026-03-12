#!/bin/bash
REPOS=(
  "/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy"
  "/Users/marek/Workspace/thisisblaze/blaze-actions"
  "/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core"
)

FILES=(
  ".cursorrules"
  ".github/copilot-instructions.md"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/dependabot.yml"
  ".antigravityignore"
  ".cursorignore"
  ".gitignore"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  "LICENSE"
  "README.md"
  "docs/AI_CONTEXT_GOVERNANCE.md"
  ".agent/config.yml"
  ".agent/workflows/09-maintain-docs.md"
)

for repo in "${REPOS[@]}"; do
  echo "--- Checking repo: $(basename "$repo") ---"
  
  # Missing files
  for f in "${FILES[@]}"; do
    if [ ! -f "$repo/$f" ]; then
      echo "MISSING: $f"
    fi
  done
  
  # Gitignore patterns
  if [ -f "$repo/.gitignore" ]; then
    if ! grep -Eq "\*\*/\.DS_Store" "$repo/.gitignore"; then echo "MISSING in .gitignore: **/.DS_Store"; fi
    if ! grep -Eq "^scratch/$" "$repo/.gitignore"; then echo "MISSING in .gitignore: scratch/"; fi
    if ! grep -Eq "\*\.log$" "$repo/.gitignore"; then echo "MISSING in .gitignore: *.log"; fi
    if ! grep -Eq "\*\.tmp$|\temp$" "$repo/.gitignore"; then echo "MISSING in .gitignore: *.tmp/temp"; fi
    if ! grep -Eq "^\.env$|^\.secrets$" "$repo/.gitignore"; then echo "MISSING in .gitignore: .env/.secrets"; fi
    
    if grep -Eq "^\.agent/" "$repo/.gitignore"; then
      echo "ILLEGAL in .gitignore: .agent/"
    fi
  fi
done
