import sys

files = [
    ".github/workflows/02-deploy-aws.yml",
    ".github/workflows/02-deploy-gcp.yml",
    ".github/workflows/02-deploy-azure.yml",
    ".github/workflows/02-deploy-pages.yml"
]

cache_step = """      - name: Cache Next.js & NPM
        uses: actions/cache@v4
        with:
          path: |
            ~/.npm
            packages/admin/.next/cache
          key: ${{ runner.os }}-nextjs-${{ hashFiles('**/package-lock.json') }}-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-nextjs-${{ hashFiles('**/package-lock.json') }}-
"""

for file in files:
    with open(file, 'r') as f:
        data = f.read()

    # Find the setup-node step in the build-admin job
    if "uses: actions/setup-node@v4" in data:
        # We need to insert the cache step after the setup-node block
        # The block looks like:
        #      - name: Setup Node
        #        uses: actions/setup-node@v4
        #        with:
        #          node-version: "20"
        #          registry-url: "https://registry.npmjs.org"
        #      - name: Create .npmrc
        
        target = 'registry-url: "https://registry.npmjs.org"\n'
        if target in data and "Cache Next.js" not in data:
            data = data.replace(target, target + cache_step)
            with open(file, 'w') as f:
                f.write(data)
            print(f"Patched {file}")
