#!/bin/bash
set -e

REGION="eu-west-1"
PROFILE="b9-blaze-dev-byte9admin"
VPC_ID="vpc-031151dd2c07f8ab7"
NAT_GW_ID="nat-009ab3d098b4d99b0"
NAMESPACE_ID="ns-m5ma2nuo42ice5ul" # ID for thisisblaze-dev.local

echo "Using profile: $PROFILE in region: $REGION"
export AWS_PROFILE=$PROFILE
export AWS_REGION=$REGION

# 1. Delete NAT Gateway
echo "Deleting NAT Gateway $NAT_GW_ID..."
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID || true
echo "Waiting for NAT Gateway to be deleted..."
aws ec2 wait nat-gateway-deleted --nat-gateway-ids $NAT_GW_ID

# Wait for ENIs associated with NAT GW to be deleted (sometimes takes a moment after NAT is deleted)
echo "Allowing time for ENI detachments..."
sleep 15

# 2. Find and delete Subnets
echo "Finding Subnets for VPC $VPC_ID..."
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text | tr '\t' '\n')
for SUBNET in $SUBNETS; do
    if [ -n "$SUBNET" ]; then
        echo "Deleting Subnet $SUBNET..."
        aws ec2 delete-subnet --subnet-id $SUBNET || true
    fi
done

# 3. Find and delete IGW
echo "Finding IGWs for VPC $VPC_ID..."
IGWS=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[*].InternetGatewayId' --output text | tr '\t' '\n')
for IGW in $IGWS; do
    if [ -n "$IGW" ]; then
        echo "Detaching IGW $IGW..."
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID || true
        echo "Deleting IGW $IGW..."
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW || true
    fi
done

# 4. Find and delete Route Tables (except main)
echo "Finding Route Tables for VPC $VPC_ID..."
RTS=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[0].Main != `true`].RouteTableId' --output text | tr '\t' '\n')
for RT in $RTS; do
    if [ -n "$RT" ]; then
        echo "Deleting Route Table $RT..."
        aws ec2 delete-route-table --route-table-id $RT || true
    fi
done

# Delete Security Groups (except default)
echo "Finding Security Groups for VPC $VPC_ID..."
SGS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName != `default`].GroupId' --output text | tr '\t' '\n')
for SG in $SGS; do
    if [ -n "$SG" ]; then
        echo "Deleting Security Group $SG..."
        aws ec2 delete-security-group --group-id $SG || true
    fi
done

# 5. Delete VPC
echo "Deleting VPC $VPC_ID..."
aws ec2 delete-vpc --vpc-id $VPC_ID || true

# 6. Delete Cloud Map Namespace
echo "Deleting Cloud Map Namespace $NAMESPACE_ID..."
aws servicediscovery delete-namespace --id $NAMESPACE_ID || true

# 7. Deregister Task Definitions
echo "Deregistering anomalous ECS Task Definitions..."
# Auto-pagination is on by default in AWS CLI
TASK_DEFS=$(aws ecs list-task-definitions --query 'taskDefinitionArns' --output text | tr '\t' '\n' | grep -E "blaze-thisisblaze--|blaze-thisisblaze-dev-") || true
if [ -n "$TASK_DEFS" ]; then
    for TASK in $TASK_DEFS; do
        if [ -n "$TASK" ]; then
            echo "Deregistering $TASK..."
            aws ecs deregister-task-definition --task-definition $TASK > /dev/null || true
        fi
    done
fi

echo "Cleanup complete!"
