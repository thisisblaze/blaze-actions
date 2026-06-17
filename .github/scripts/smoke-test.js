const { test } = require('node:test');
const assert = require('node:assert');

test('Basic routing stability post-deployment', async () => {
  const url = process.env.SMOKE_TEST_URL;
  if (!url) {
    assert.fail('SMOKE_TEST_URL environment variable is required');
  }

  console.log(`🔍 Hitting smoke test URL: ${url}`);
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'application/json, text/html, */*'
      },
      // Set a timeout of 10 seconds
      signal: AbortSignal.timeout(10000)
    });
    
    console.log(`Response HTTP Status: ${response.status}`);
    assert.strictEqual(response.status, 200, `Post-deploy smoke test failed with status ${response.status}`);
    
    // Optionally check response body
    const body = await response.text();
    assert.ok(body.length > 0, 'Response body should not be empty');
    
    console.log('✅ Smoke test passed with 200 OK!');
  } catch (error) {
    assert.fail(`Smoke test request failed: ${error.message}`);
  }
});
