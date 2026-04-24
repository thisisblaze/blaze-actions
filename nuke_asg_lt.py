import boto3
import time

region = "eu-west-1"
asg_name = "blaze-b9-thisisblaze-dev-ecs-ec2-cp-asg"
lt_name = "blaze-b9-thisisblaze-dev-ecs-ec2-cp-lt"

autoscaling = boto3.client('autoscaling', region_name=region)
ec2 = boto3.client('ec2', region_name=region)

print(f"Deleting ASG: {asg_name}")
try:
    instances = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])['AutoScalingGroups']
    if instances:
        instance_ids = [i['InstanceId'] for i in instances[0]['Instances']]
        if instance_ids:
            print(f"Disabling scale-in protection on {instance_ids}")
            autoscaling.set_instance_protection(InstanceIds=instance_ids, AutoScalingGroupName=asg_name, ProtectedFromScaleIn=False)
        print("Deleting ASG forcefully...")
        autoscaling.delete_auto_scaling_group(AutoScalingGroupName=asg_name, ForceDelete=True)
        print("ASG deletion initiated. Waiting for ASG to be fully deleted...")
        while True:
            res = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])['AutoScalingGroups']
            if not res:
                break
            print("Still deleting...")
            time.sleep(10)
        print("ASG fully deleted.")
except Exception as e:
    print(f"ASG Error: {e}")

print(f"Deleting Launch Template: {lt_name}")
try:
    ec2.delete_launch_template(LaunchTemplateName=lt_name)
    print("Launch template deleted.")
except Exception as e:
    print(f"LT Error: {e}")

