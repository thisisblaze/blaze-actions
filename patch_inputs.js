const fs = require('fs');

function patch(file) {
  let content = fs.readFileSync(file, 'utf8');

  // Add tf_vars to inputs
  if (!content.includes('      tf_vars:\n        description:')) {
    content = content.replace(
      '      wif_audience:',
      '      tf_vars:\n        description: "Variables string to write to _github_vars.env"\n        required: false\n        type: string\n      wif_audience:'
    );
  }

  fs.writeFileSync(file, content);
}

patch('.github/workflows/reusable-dns-handoff.yml');
patch('.github/workflows/reusable-dns-verify.yml');
