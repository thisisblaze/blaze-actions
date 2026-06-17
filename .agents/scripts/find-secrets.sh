#!/bin/bash
# .antigravity/scripts/find-secrets.sh
# Scans the codebase for high-risk secret patterns.

echo "🔍 Scanning for secrets..."

# Define patterns to search for
PATTERNS=(
  "PWD="
  "PASSWORD="
  "API_KEY="
  "ACCESS_KEY_ID="
  "SECRET_ACCESS_KEY="
  "ghp_"
  "npm_"
  "sk_live_"
)

FAILED=0

for pattern in "${PATTERNS[@]}"; do
  # Grep recursively, exclude .git and node_modules
  # We look for the pattern followed by a non-variable assignment
  matches=$(grep -r "$pattern" . \
    --exclude-dir={.git,node_modules,.terraform,dist,build} \
    --exclude={find-secrets.sh,package-lock.json,yarn.lock} \
    | grep -v "\$" \
    | grep -v "{{" )
  
  if [ ! -z "$matches" ]; then
    echo "❌ Potential secret found: $pattern"
    echo "$matches"
    FAILED=1
  fi
done

if [ $FAILED -eq 0 ]; then
  echo "✅ No obvious secrets found."
  exit 0
else
  echo "⚠️  Suspicious patterns detected. Please review."
  exit 1
fi
