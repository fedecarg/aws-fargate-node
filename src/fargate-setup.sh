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

task_definition_file="${SCRIPT_DIR}/ecs/output/task-definition-${GIT_REVISION}.json"
touch $task_definition_file
echo "${TASK_DEFINITION}" > $task_definition_file

echo "Registering Task Definition..."
aws ecs register-task-definition --cli-input-json file://$task_definition_file


#===============================================================================
# TODO: Create Service
#===============================================================================

source $SCRIPT_DIR/ecs/service-definition-template.sh

service_definition_file="${SCRIPT_DIR}/ecs/output/service-definition-${GIT_REVISION}.json"
touch $service_definition_file
echo "${SERVICE_DEFINITION}" > $service_definition_file

echo "Creating Service..."
aws ecs create-service --region "${AWS_REGION}" --cli-input-json file://$service_definition_file

#EOF