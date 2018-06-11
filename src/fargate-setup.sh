#!/bin/bash

#===============================================================================
# Load config file
#===============================================================================

# Absolute path to this directory
SCRIPT_DIR=$(cd $(dirname "$0"); pwd)
source $SCRIPT_DIR/fargate-config.sh


#===============================================================================
# Login to AWS
#===============================================================================

export AWS_DEFAULT_PROFILE

echo "Sending credentials to AWS..."
$(aws ecr get-login --no-include-email --region $AWS_REGION)

[ $? -ne 0 ] && exit 1


#===============================================================================
# Create ECS Cluster
#===============================================================================

echo "Creating ECS Cluster..."
aws ecs create-cluster --cluster-name $ECS_CLUSTER_NAME


#===============================================================================
# Create ECR Repository
#===============================================================================

echo "Creating ECR Repository..."
aws ecr create-repository --repository-name $ECR_NAME


#===============================================================================
# Register Task Definition
#===============================================================================

source $SCRIPT_DIR/ecs/task-definition-template.sh

echo "Registering Task Definition..."
aws ecs register-task-definition --cli-input-json file://$SCRIPT_DIR/ecs/tasks/task-definition-$GIT_REVISION.json

touch $SCRIPT_DIR/ecs/tasks/task-definition-$GIT_REVISION.json
echo "${TASK_DEFINITION}" > $SCRIPT_DIR/ecs/tasks/task-definition-$GIT_REVISION.json


#===============================================================================
# TODO: Create Service
#===============================================================================

# https://docs.aws.amazon.com/cli/latest/reference/ecs/create-service.html