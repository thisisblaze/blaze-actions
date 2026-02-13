#!/bin/bash
# .antigravity/scripts/validate-docs.sh
# Validates documentation structure.

echo "🔍 Validating documentation structure..."

DOCS_DIR="docs"
REPORTS_DIR="$DOCS_DIR/reports"
FAILED=0

# 1. Check for loose files in docs/reports/
if [ -d "$REPORTS_DIR" ]; then
  loose_files=$(find "$REPORTS_DIR" -maxdepth 1 -type f -name "*.md" -not -name "README.md" -not -name "INDEX.md")
  
  if [ ! -z "$loose_files" ]; then
    echo "❌ Found loose files in $REPORTS_DIR (Move to YYYY/MM/):"
    echo "$loose_files"
    FAILED=1
  else
    echo "✅ No loose reports found."
  fi
fi

# 2. Check for existence of essential files
REQUIRED_FILES=(
  "docs/README.md"
  "docs/AI_CONTEXT_GOVERNANCE.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ Missing required file: $file"
    FAILED=1
  else
    echo "✅ Found $file"
  fi
done

if [ $FAILED -eq 0 ]; then
  echo "✅ Documentation structure is valid."
  exit 0
else
  echo "❌ Validation failed."
  exit 1
fi
