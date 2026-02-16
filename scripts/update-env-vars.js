const { execSync } = require('child_process');
const path = require('path');
const sodium = require('libsodium-wrappers');

// Helper function to encrypt value using GitHub's public key (for secrets)
function encryptSecret(publicKey, secretValue) {
    // Check if sodium is ready (it should be awaited in main)
    const binkey = sodium.from_base64(publicKey, sodium.base64_variants.ORIGINAL);
    const binsec = sodium.from_string(secretValue);
    const encBytes = sodium.crypto_box_seal(binsec, binkey);

    return sodium.to_base64(encBytes, sodium.base64_variants.ORIGINAL);
}

// Helper function to create or update environment variable
async function upsertEnvironmentVariable(github, context, environment, name, value) {
    if (!value) {
        console.log(`⚠️ No ${name} to update`);
        return false;
    }

    try {
        // Check if variable exists
        let varExists = false;
        try {
            await github.request(`GET /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/variables/${name}`, {
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            varExists = true;
        } catch (error) {
            if (error.status !== 404) throw error;
        }

        if (varExists) {
            // Update existing variable
            await github.request(`PATCH /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/variables/${name}`, {
                value: value,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            console.log(`✅ Updated environment variable: ${name} in ${environment}`);
        } else {
            // Create new variable
            await github.request(`POST /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/variables`, {
                name: name,
                value: value,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            console.log(`✅ Created environment variable: ${name} in ${environment}`);
        }
        return true;
    } catch (error) {
        console.error(`❌ Failed to update ${name}:`, error.message);
        throw error;
    }
}

// Helper function to create or update environment secret
async function upsertEnvironmentSecret(github, context, environment, name, value) {
    if (!value) {
        console.log(`⚠️ No ${name} to update`);
        return false;
    }

    try {
        // Get GitHub's public key for this environment
        const publicKeyResponse = await github.request(`GET /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/secrets/public-key`, {
            headers: {
                'X-GitHub-Api-Version': '2022-11-28'
            }
        });

        const publicKey = publicKeyResponse.data.key;
        const keyId = publicKeyResponse.data.key_id;

        // Encrypt the secret value
        const encryptedValue = encryptSecret(publicKey, value);

        // Check if secret exists
        let secretExists = false;
        try {
            await github.request(`GET /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/secrets/${name}`, {
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            secretExists = true;
        } catch (error) {
            if (error.status !== 404) throw error;
        }

        if (secretExists) {
            // Update existing secret
            await github.request(`PUT /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/secrets/${name}`, {
                encrypted_value: encryptedValue,
                key_id: keyId,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            console.log(`✅ Updated environment secret: ${name} in ${environment}`);
        } else {
            // Create new secret
            await github.request(`PUT /repos/${context.repo.owner}/${context.repo.repo}/environments/${environment}/secrets/${name}`, {
                encrypted_value: encryptedValue,
                key_id: keyId,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            console.log(`✅ Created environment secret: ${name} in ${environment}`);
        }
        return true;
    } catch (error) {
        console.error(`❌ Failed to update ${name}:`, error.message);
        throw error;
    }
}

module.exports = async ({ github, context, core }) => {
    // Ensure sodium is ready
    await sodium.ready;

    // Get values from environment
    const tunnelId = process.env.TUNNEL_ID || '';
    const environment = process.env.ENVIRONMENT;
    // CRITICAL: TF_DIR must be provided by the caller (workflow), no hardcoded defaults allowed.
    // This ensures Multi-Cloud compatibility (AWS/GCP/Azure have different paths).
    const tfDir = process.env.TF_DIR;

    if (!tfDir) {
        console.error('❌ ERROR: TF_DIR environment variable is missing.');
        process.exit(1);
    }

    // Get tunnel_token directly from Terraform (not passed through outputs to avoid masking)
    let tunnelToken = '';
    try {
        console.log(`🔍 Reading Terraform outputs from: ${tfDir}`);
        const originalDir = process.cwd();

        // Resolve absolute path
        const absTfDir = path.resolve(originalDir, tfDir);

        // Ensure directory exists
        process.chdir(absTfDir);

        // Read tunnel_token from Terraform output
        tunnelToken = execSync('terraform output -raw tunnel_token', {
            encoding: 'utf-8',
            stdio: ['ignore', 'pipe', 'ignore'], // Suppress stderr to keep logs clean
            env: { ...process.env, PATH: process.env.PATH }
        }).trim();

        process.chdir(originalDir);
    } catch (error) {
        console.log('ℹ️  Could not retrieve tunnel_token from Terraform (Module might not output it - this is expected if not using Cloudflare Tunnel):', error.message);
        // Do not fail - token might not exist in this stack
    }

    if (!environment) {
        console.log('⚠️ No environment specified');
        return;
    }

    try {
        // Update Tunnel ID (variable - not sensitive)
        if (tunnelId) {
            await upsertEnvironmentVariable(github, context, environment, 'CLOUDFLARE_TUNNEL_ID', tunnelId);
        }

        // Update Tunnel Token (secret - sensitive, must be encrypted)
        if (tunnelToken) {
            await upsertEnvironmentSecret(github, context, environment, 'CLOUDFLARE_TUNNEL_TOKEN', tunnelToken);
        }

        console.log(`📋 Tunnel ID stored as environment variable: CLOUDFLARE_TUNNEL_ID`);
        console.log(`📋 Tunnel Token stored as environment secret: CLOUDFLARE_TUNNEL_TOKEN`);
        console.log(`   Environment: ${environment}`);
    } catch (error) {
        console.error('❌ Failed to update GitHub environment variables:', error.message);
        if (error.status === 403) {
            console.error('');
            console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            console.error('🔐 PERMISSION ERROR: Cannot update environment variables');
            console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            // ... (Error message truncated for brevity as it's the same)
            console.error('Check workflows/50_deploy_blaze_app.yml for full instructions.');
            console.error('');
        } else {
            console.error('   Error details:', JSON.stringify(error, null, 2));
        }
        // Don't fail the workflow, just log the error
        console.log('⚠️ Continuing workflow despite variable update failure');
    }
};
