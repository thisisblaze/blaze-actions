import sys

with open('.github/workflows/reusable-dns-verify.yml', 'r') as f:
    content = f.read()

close_job = """
  close-issue:
    name: "Close DNS Handoff Issue"
    needs: verify
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - name: Checkout Code
        uses: actions/checkout@v6.0.2

      - name: Update State and Close Issue
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          JSON_FILE="docs/dns-handoff/state/${{ inputs.environment }}.json"
          if [ -f "$JSON_FILE" ]; then
            # Update state to completed
            tmp=$(mktemp)
            jq '.status = "completed"' "$JSON_FILE" > "$tmp" && mv "$tmp" "$JSON_FILE"
            
            git config user.name "github-actions[bot]"
            git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
            git add docs/dns-handoff/state/
            git commit -m "docs: DNS handoff completed for ${{ inputs.environment }}"
            git push
          fi
          
          ISSUE_TITLE="DNS handoff: ${{ inputs.environment }}"
          ISSUE_NUMBER=$(gh issue list --search "in:title \"$ISSUE_TITLE\"" --state open --json number -q '.[0].number')
          
          if [ -n "$ISSUE_NUMBER" ] && [ "$ISSUE_NUMBER" != "null" ]; then
            gh issue comment "$ISSUE_NUMBER" --body "✅ DNS verification successful! Certificate validated and CDN updated. Closing handoff."
            gh issue close "$ISSUE_NUMBER"
          fi
"""

content = content + close_job

with open('.github/workflows/reusable-dns-verify.yml', 'w') as f:
    f.write(content)

print("Patched reusable-dns-verify.yml again")
