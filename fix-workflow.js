const fs = require('fs');

let file = fs.readFileSync('.github/workflows/stress-test-azure.yml', 'utf8');

// 1. Remove calculate-config from setup job and its outputs
file = file.replace(/      project_key: \$\{\{ steps\.config\.outputs\.project_key \}\}\n/g, '');
file = file.replace(/      client_key: \$\{\{ steps\.config\.outputs\.client_key \}\}\n/g, '');
file = file.replace(/      stage_key: \$\{\{ steps\.config\.outputs\.stage_key \}\}\n/g, '');
file = file.replace(/      namespace: \$\{\{ steps\.config\.outputs\.namespace \}\}\n/g, '');
file = file.replace(/      domain_root: \$\{\{ steps\.config\.outputs\.domain_root \}\}\n/g, '');
file = file.replace(/      aws_region: \$\{\{ steps\.config\.outputs\.aws_region \}\}.*\n/g, '');

file = file.replace(/      - name: Calculate Configuration\n\s+id: config\n\s+uses: thisisblaze\/blaze-actions\/\.github\/actions\/calculate-config@dev\n\s+with:\n\s+environment:.*\n\s+project:.*\n\s+cloud_provider:.*\n\n/g, '');

// 2. Add config job
const configJob = `
  config:
    name: ⚙️ Config
    needs: [setup]
    uses: ./.github/workflows/reusable-calculate-config.yml
    with:
      environment: \${{ inputs.environment }}
      cloud_provider: "azure"
`;
file = file.replace(/  # ── SAFETY ─────────────────────────────────────────────────────────────/, configJob.trim() + '\n\n  # ── SAFETY ─────────────────────────────────────────────────────────────');

// 3. Fix check-state job
file = file.replace(/    needs: \[setup, prod-safety-check\]/, '    needs: [setup, config, prod-safety-check]');
file = file.replace(/      - name: Calculate Config\n\s+id: config\n\s+uses: thisisblaze\/blaze-actions\/\.github\/actions\/calculate-config@dev\n\s+with:\n\s+environment:.*\n\s+project:.*\n\s+cloud_provider:.*\n\n/g, '');
file = file.replace(/\$\{\{ steps\.config\.outputs\./g, '${{ needs.config.outputs.');


// 4. Fix deploy-api and deploy-frontend
file = file.replace(/    needs: \[setup, provision-app\]/, '    needs: [setup, config, provision-app]');
file = file.replace(/    needs: \[setup, deploy-api\]/, '    needs: [setup, config, deploy-api]');
file = file.replace(/\$\{\{ needs\.setup\.outputs\.project_key \}\}/g, '${{ needs.config.outputs.project_key }}');
file = file.replace(/\$\{\{ needs\.setup\.outputs\.client_key \}\}/g, '${{ needs.config.outputs.client_key }}');
file = file.replace(/\$\{\{ needs\.setup\.outputs\.stage_key \}\}/g, '${{ needs.config.outputs.stage_key }}');
file = file.replace(/\$\{\{ needs\.setup\.outputs\.namespace \}\}/g, '${{ needs.config.outputs.namespace }}');
file = file.replace(/\$\{\{ needs\.setup\.outputs\.domain_root \}\}/g, '${{ needs.config.outputs.domain_root }}');
file = file.replace(/\$\{\{ needs\.setup\.outputs\.aws_region \}\}/g, '${{ needs.config.outputs.aws_region }}');

// Remove any remaining needs.setup.outputs that were meant to be config outputs just in case
// but the above covers the ones we explicitly passed.

fs.writeFileSync('.github/workflows/stress-test-azure.yml', file);
console.log("Replaced successfully!");
