with open(".github/workflows/02-deploy-app.yml", "r") as f:
    content = f.read()

# Add to workflow_call secrets
content = content.replace(
"""    secrets:
      BLAZE_ELASTICSEARCH_USERNAME:""",
"""    secrets:
      BASIC_AUTH_CREDENTIALS:
        required: false
      BLAZE_ELASTICSEARCH_USERNAME:""")

# Add to dispatch jobs secrets
content = content.replace(
"""    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}""",
"""    secrets:
      BASIC_AUTH_CREDENTIALS: ${{ secrets.BASIC_AUTH_CREDENTIALS }}
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}""")

with open(".github/workflows/02-deploy-app.yml", "w") as f:
    f.write(content)
