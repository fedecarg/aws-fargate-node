#
# Container Definition Parameters
# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html
#
# Container definitions are used in task definitions to describe the different containers that are launched 
# as part of a task. 
#
CONTAINER_DEFINITION=$(cat <<-EOF
{
    "name": "${ECR_CONTAINER_NAME}", 
    "image": "${ECR_IMAGE}", 
    "portMappings": [{
        "protocol": "tcp",
        "containerPort": ${APP_PORT}, 
        "hostPort": ${APP_PORT}
    }], 
    "cpu": ${ECS_CPU},
    "memory": ${ECS_MEMORY},
    "environment": [{
      "name": "APP_PORT",
      "value": "${APP_PORT}"
    },{
      "name": "APP_ENV",
      "value": "${APP_ENV}"
    },{
      "name": "GIT_BRANCH",
      "value": "${GIT_CURRENT_BRANCH}"
    },{
      "name": "GIT_REVISION",
      "value": "${GIT_REVISION}"
    },{
      "name": "GIT_USER",
      "value": "${GIT_USER}"
    }],
    "essential": true
}
EOF
)

#
# Task Definition Parameters
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
# 
# The family and container definitions are required in a task definition, while task role, network mode, 
# volumes, task placement constraints, and launch type are optional.
#
TASK_DEFINITION=$(cat <<-EOF
{
    "family": "${ECS_TASK_NAME}", 
    "networkMode": "awsvpc", 
    "executionRoleArn": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole",
    "containerDefinitions": [
        ${CONTAINER_DEFINITION}
    ], 
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "${ECS_CPU}", 
    "memory": "${ECS_MEMORY}"
}
EOF
)