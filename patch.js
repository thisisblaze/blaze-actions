const fs = require('fs');
const file = '/Users/marek/Workspace/thisisblaze/blaze-actions/.github/workflows/reusable-docker-build.yml';
let content = fs.readFileSync(file, 'utf8');
content = content.replaceAll(
  'run: gcloud auth configure-docker ${{ inputs.gcp_region }}-docker.pkg.dev --quiet',
  'uses: docker/login-action@v3\n        with:\n          registry: ${{ inputs.gcp_region }}-docker.pkg.dev\n          username: oauth2accesstoken\n          password: ${{ steps.auth.outputs.access_token }}'
);
content = content.replaceAll(
  'uses: google-github-actions/auth@v3',
  'id: auth\n        uses: google-github-actions/auth@v3'
);
fs.writeFileSync(file, content);
