import sys

with open('.github/workflows/reusable-dns-handoff.yml', 'r') as f:
    content = f.read()

summary_job = """  summary:
    name: "Render DNS Handoff Summary (Phase B)"
    needs: handoff
    runs-on: ubuntu-latest
    if: ${{ needs.handoff.outputs.dns_handoff_records_json != '' && needs.handoff.outputs.dns_handoff_records_json != '[]' }}
    permissions:
      contents: write
      issues: write
    steps:
      - name: Checkout Code
        uses: actions/checkout@v6.0.2

      - name: Render Markdown and JSON State
        run: |
          mkdir -p docs/dns-handoff/state
          
          # Render Markdown
          MD_FILE="docs/dns-handoff/${{ inputs.environment }}.md"
          echo "## 🌐 DNS Handoff Required for ${{ inputs.environment }}" > "$MD_FILE"
          echo "The following DNS records must be created manually before proceeding to Phase C:" >> "$MD_FILE"
          echo "" >> "$MD_FILE"
          echo "| Name | Type | Value | Host |" >> "$MD_FILE"
          echo "|------|------|-------|------|" >> "$MD_FILE"
          echo '${{ needs.handoff.outputs.dns_handoff_records_json }}' | jq -r '.[] | "| \\(.name) | \\(.type) | \\(.value) | \\(.host) |"' >> "$MD_FILE"
          
          # Render JSON State
          JSON_FILE="docs/dns-handoff/state/${{ inputs.environment }}.json"
          echo "{\"status\": \"pending\", \"records\": ${{ needs.handoff.outputs.dns_handoff_records_json }}}" > "$JSON_FILE"
          
          # Also append to step summary
          cat "$MD_FILE" >> $GITHUB_STEP_SUMMARY

      - name: Commit and Push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add docs/dns-handoff/
          # Only commit if there are changes
          if git diff --staged --quiet; then
            echo "No changes to commit"
          else
            git commit -m "docs: DNS handoff requirements for ${{ inputs.environment }}"
            git push
          fi

      - name: Open or Update GitHub Issue
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          ISSUE_TITLE="DNS handoff: ${{ inputs.environment }}"
          MD_FILE="docs/dns-handoff/${{ inputs.environment }}.md"
          
          # Check if issue exists
          ISSUE_NUMBER=$(gh issue list --search "in:title \"$ISSUE_TITLE\"" --state open --json number -q '.[0].number')
          
          if [ -z "$ISSUE_NUMBER" ] || [ "$ISSUE_NUMBER" == "null" ]; then
            gh issue create --title "$ISSUE_TITLE" --body-file "$MD_FILE"
          else
            gh issue comment "$ISSUE_NUMBER" --body-file "$MD_FILE"
          fi
"""

# replace the existing summary job
parts = content.split('  summary:')
new_content = parts[0] + summary_job

with open('.github/workflows/reusable-dns-handoff.yml', 'w') as f:
    f.write(new_content)

print("Patched reusable-dns-handoff.yml")
