#!/bin/bash
# 
# USAGE: ./setup-github-oidc.sh <github_org> <repo_name> [<aws_region>] [<role_name>] [<aws_profile>]
# 
# Example: ./setup-github-oidc.sh my-org my-template-repo eu-west-1 CustomGitHubRole my-profile
# 
# ./setup-github-oidc.sh thebyte9 blaze-template-deploy eu-west-1 BlazeGitHubActionsRole default

set -e

# 1. READ ARGUMENTS AND SET DEFAULTS
GITHUB_ORG=$1
REPO_NAME=$2
AWS_REGION=${3:-"eu-west-1"}  # Default to eu-west-1 if not provided
ROLE_NAME=${4:-"BlazeGitHubActionsRole-${REPO_NAME}"} # Default role name
AWS_PROFILE=${5}

if [ -n "$AWS_PROFILE" ]; then
  export AWS_PROFILE="$AWS_PROFILE"
fi

if [ -z "$GITHUB_ORG" ] || [ -z "$REPO_NAME" ]; then
  echo "🚨 ERROR: Missing required arguments. Usage: $0 <github_org> <repo_name>"
  exit 1
fi

echo "--- AWS OIDC SETUP ---"
echo "Org/Repo: $GITHUB_ORG/$REPO_NAME"
echo "AWS Region: $AWS_REGION"
echo "IAM Role: $ROLE_NAME"
if [ -n "$AWS_PROFILE" ]; then
  echo "AWS Profile: $AWS_PROFILE"
fi
echo "----------------------"

# --- AWS CONFIG ---
# Assuming AWS CLI is configured via environment variables or profile
export AWS_REGION="$AWS_REGION" 

echo "1. Creating OIDC Provider (Safe to run multiple times)..."
# The thumbprint is a standard value for GitHub Actions OIDC
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --region $AWS_REGION 2>/dev/null || echo "✅ Provider might already exist or was created successfully."

echo "2. Creating Trust Policy..."
# Dynamic policy ensures only this specific repo can assume the role
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          # Security boundary is dynamic based on input
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${REPO_NAME}:*"
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

echo "3. Creating or Updating Role $ROLE_NAME..."
# Try to create the role, if it fails, try to update the assume-role-policy
if ! aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust-policy.json 2>/dev/null; then
    echo "   Role already exists. Updating its Trust Policy."
    aws iam update-assume-role-policy --role-name $ROLE_NAME --policy-document file://trust-policy.json
fi

echo "4. Creating Custom IAM Policy..."
cat <<EOF > github-actions-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "ec2:Describe*",
        "ec2:CreateTags",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:DescribeNetworkInterfaces",
        "iam:GetRole",
        "iam:PassRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "logs:*",
        "application-autoscaling:*",
        "codedeploy:*",
        "elasticloadbalancing:*",
        "s3:*",
        "dynamodb:*",
        "efs:*",
        "servicediscovery:*",
        "acm:*",
        "route53:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

POLICY_NAME="BlazeGitHubActionsPolicy"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Try to create policy, or create new version if exists
if aws iam create-policy --policy-name $POLICY_NAME --policy-document file://github-actions-policy.json 2>/dev/null; then
  echo "   ✅ Policy created successfully."
else
  echo "   Policy exists. Creating new version..."
  aws iam create-policy-version \
    --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/$POLICY_NAME" \
    --policy-document file://github-actions-policy.json \
    --set-as-default 2>/dev/null || echo "   Policy version might already be up to date."
fi

POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/$POLICY_NAME"
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN

rm github-actions-policy.json

echo "--- DONE ---"
echo "✅ Role $ROLE_NAME is ready. Add its ARN to your GitHub Secrets as AWS_ROLE_ARN:"
# Retrieve the ARN to be copied by the user
aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text

rm trust-policy.json