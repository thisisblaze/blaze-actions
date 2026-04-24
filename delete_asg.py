import boto3
import sys

region = "eu-west-1"
asg_name = "blaze-b9-thisisblaze-dev-ecs-ec2-cp-asg"

autoscaling = boto3.client('autoscaling', region_name=region)

print(f"Deleting ASG: {asg_name}")
try:
    instances = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])['AutoScalingGroups'][0]['Instances']
    instance_ids = [i['InstanceId'] for i in instances]
    if instance_ids:
        print(f"Disabling scale-in protection on {instance_ids}")
        autoscaling.set_instance_protection(InstanceIds=instance_ids, AutoScalingGroupName=asg_name, ProtectedFromScaleIn=False)
    
    print("Deleting ASG forcefully...")
    autoscaling.delete_auto_scaling_group(AutoScalingGroupName=asg_name, ForceDelete=True)
    print("ASG deleted.")
except Exception as e:
    print(f"Error: {e}")

