import os
import glob

files = glob.glob(".github/workflows/02-deploy-*.yml")

for file in files:
    with open(file, "r") as f:
        content = f.read()
    
    # Restore original content by removing the incorrect replacements
    content = content.replace("      BASIC_AUTH_CREDENTIALS:\n        required: false\n", "")
    
    # Add to workflow_call secrets
    content = content.replace(
"""    secrets:
      BLAZE_ELASTICSEARCH_USERNAME:""",
"""    secrets:
      BASIC_AUTH_CREDENTIALS:
        required: false
      BLAZE_ELASTICSEARCH_USERNAME:""")

    # For the jobs passing secrets, just add it properly if AWS_ROLE_ARN is there
    # Let's do it by regex or simply:
    content = content.replace(
"""    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}""",
"""    secrets:
      BASIC_AUTH_CREDENTIALS: ${{ secrets.BASIC_AUTH_CREDENTIALS }}
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}""")

    with open(file, "w") as f:
        f.write(content)
