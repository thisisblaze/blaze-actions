import sys

with open('.github/workflows/reusable-dns-verify.yml', 'r') as f:
    content = f.read()

# Replace manage_dns=true with manage_dns=false
content = content.replace('manage_dns=true', 'manage_dns=false')

# We need to add a job before verify, but wait, `verify` uses `reusable-terraform.yml`.
# Reusable workflows cannot be called as a step, they must be a job.
# So we add a `check-dns` job and make `verify` depend on it.

check_job = """  check-dns:
    name: "Check DNS Resolution"
    runs-on: ubuntu-latest
    outputs:
      ready: ${{ steps.check.outputs.ready }}
    steps:
      - name: Checkout Code
        uses: actions/checkout@v6.0.2

      - name: Verify DNS Records
        id: check
        run: |
          STATE_FILE="docs/dns-handoff/state/${{ inputs.environment }}.json"
          if [ ! -f "$STATE_FILE" ]; then
            echo "State file not found. Nothing to verify."
            echo "ready=false" >> $GITHUB_OUTPUT
            exit 0
          fi
          
          # We should parse the JSON and check each record using dig.
          # For simplicity, if jq and dig are available:
          RECORDS=$(jq -c '.records[]' "$STATE_FILE")
          
          ALL_RESOLVED=true
          for row in $RECORDS; do
            NAME=$(echo "$row" | jq -r '.name')
            TYPE=$(echo "$row" | jq -r '.type')
            EXPECTED_VALUE=$(echo "$row" | jq -r '.value')
            
            # Use 1.1.1.1 to resolve
            RESOLVED_VALUE=$(dig +short $TYPE $NAME @1.1.1.1 | tail -n1 | sed 's/"//g')
            
            if [[ "$RESOLVED_VALUE" == *"$EXPECTED_VALUE"* ]] || [[ "$EXPECTED_VALUE" == *"$RESOLVED_VALUE"* ]]; then
              echo "✅ $NAME resolves to $RESOLVED_VALUE"
            else
              echo "❌ $NAME resolves to '$RESOLVED_VALUE', expected '$EXPECTED_VALUE'"
              ALL_RESOLVED=false
            fi
          done
          
          if [ "$ALL_RESOLVED" = true ]; then
            echo "ready=true" >> $GITHUB_OUTPUT
          else
            echo "ready=false" >> $GITHUB_OUTPUT
          fi

"""

parts = content.split('  verify:')
new_content = parts[0] + check_job + "  verify:\n    needs: check-dns\n    if: ${{ needs.check-dns.outputs.ready == 'true' }}" + parts[1].replace('uses: thisisblaze/blaze-actions', '\n    uses: thisisblaze/blaze-actions')

with open('.github/workflows/reusable-dns-verify.yml', 'w') as f:
    f.write(new_content)

print("Patched reusable-dns-verify.yml")
