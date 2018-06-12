#
# Service Definition Parameters
# https://docs.aws.amazon.com/cli/latest/reference/ecs/create-service.html
# 
# Parameters:
#
# cluster, serviceName, taskDefinition, loadBalancers, serviceRegistries, desiredCount, clientToken, 
# launchType, platformVersion, role, deploymentConfiguration, placementConstraints, placementStrategy, 
# networkConfiguration, healthCheckGracePeriodSeconds
#
# IMPORTANT: You must have a load balancer configured in the same region as your container instances,
#            and the name should be $ELB_NAME
# 
#
SERVICE_DEFINITION=$(cat <<-EOF
{
    "cluster": "${ECS_CLUSTER_NAME}",
    "serviceName": "${ECS_SERVICE_NAME}",
    "taskDefinition": "${ECS_TASK_NAME}",
    "launchType": "FARGATE",
    "desiredCount": 2,
    "loadBalancers": [
        {
            "targetGroupArn": "${ELB_TARGET_GROUP_ARN}",
            "containerName": "${ECR_CONTAINER_NAME}",
            "containerPort": $APP_PORT
        }
    ],
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": [
                "subnet-3862b364", 
                "subnet-f3c01294"
            ],
            "securityGroups": [
                "sg-9743a9dc", 
                "sg-c1f10f8a"
            ],
            "assignPublicIp": "ENABLED"
        }
    }
}
EOF
)