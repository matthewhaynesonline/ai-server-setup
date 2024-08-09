import boto3


def lambda_handler(event, context):
    ec2 = boto3.client("ec2")

    instances = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )

    instance_ids = [
        instance["InstanceId"]
        for reservation in instances["Reservations"]
        for instance in reservation["Instances"]
    ]

    if instance_ids:
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopped instances: {instance_ids}")
    else:
        print("No running instances found.")

    return {"statusCode": 200, "body": "Stopped all running instances."}
