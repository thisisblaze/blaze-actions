const fs = require('fs');

function patch(file) {
  let content = fs.readFileSync(file, 'utf8');

  // Add tf_vars to inputs
  if (!content.includes('tf_vars:')) {
    content = content.replace(
      'wif_audience:\n        description: "WIF Audience (Optional)"\n        required: false\n        type: string',
      'wif_audience:\n        description: "WIF Audience (Optional)"\n        required: false\n        type: string\n      tf_vars:\n        description: "Variables string to write to _github_vars.env"\n        required: false\n        type: string'
    );
  }

  // Pass tf_vars to reusable-terraform.yml
  content = content.replace(
    '      tf_vars: |\n        manage_dns=false\n        await_validation=false',
    '      tf_vars: |\n        ${{ inputs.tf_vars }}\n        manage_dns=false\n        await_validation=false'
  );

  content = content.replace(
    '      tf_vars: |\n        manage_dns=true\n        await_validation=true',
    '      tf_vars: |\n        ${{ inputs.tf_vars }}\n        manage_dns=true\n        await_validation=true'
  );

  fs.writeFileSync(file, content);
}

patch('.github/workflows/reusable-dns-handoff.yml');
patch('.github/workflows/reusable-dns-verify.yml');
