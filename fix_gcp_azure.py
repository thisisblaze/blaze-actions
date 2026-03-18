import re
for f in [".github/workflows/02-deploy-gcp.yml", ".github/workflows/02-deploy-azure.yml", ".github/workflows/02-deploy-pages.yml"]:
    with open(f, "r") as file:
        content = file.read()
    
    insertion = """
      BLAZE_ELASTICSEARCH_USERNAME:
        required: false
      BLAZE_ELASTICSEARCH_PASSWORD:
        required: false
      BLAZE_ELASTICSEARCH_ENDPOINT:
        required: false
      MONGO_INITDB_ROOT_PASSWORD:
        required: false
"""
    
    if "MONGO_INITDB_ROOT_PASSWORD" not in content and "secrets:" in content:
        # Insert right after "secrets:\n"
        content = re.sub(r'([ \t]+secrets:\s*\n)', r'\1' + insertion.strip('\n') + '\n', content, count=1)
        with open(f, "w") as file:
            file.write(content)
        print(f"Patched {f}")
