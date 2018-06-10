#!/bin/bash

# Account ID number on the AWS Management Console
AWS_ACCOUNT_ID="123456"

# Named profile defined in ~/.aws/config
AWS_DEFAULT_PROFILE="myapp"

# Region defined in ~/.aws/config
AWS_REGION=$(aws configure get ${AWS_DEFAULT_PROFILE}.region)


#===============================================================================
# Amazon Elastic Container Service (ECS)
#===============================================================================

# ECS cluster name where tasks or services are grouped
ECS_CLUSTER_NAME="myapp-dev"

# A task definition is required to run Docker containers in ECS
ECS_TASK_NAME="myapp-task-dev"

# A service name is required to know which task definition to use
ECS_SERVICE_NAME="myapp-service-dev"

# CPU: 512  - Memory: 1024
# CPU: 1024 - Memory: 2048
ECS_CPU="1024"
ECS_MEMORY="2048"


#===============================================================================
# Amazon Elastic Container Registry (ECR)
#===============================================================================

# Name of the repository
ECR_NAME="myapp-repository"

# URI of the repository
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# The tag of the Docker image
ECR_TAG="${GIT_REVISION:-latest}"

# The Docker image we want to deploy
ECR_IMAGE="${ECR_URI}/${ECR_NAME}:${ECR_TAG}"


#===============================================================================
# Web application
#===============================================================================

# The environment to pass to the container
APP_ENV="${APP_ENV:-dev}"

# The port number on the container that is bound to the app
APP_PORT="${APP_PORT:-3000}"

# Relative or absolute path to the app (and Dockerfile)
APP_PATH=$(cd "${SCRIPT_DIR}/../"; pwd)


#===============================================================================
# Git
#===============================================================================

# Git release branch name (defaults to current branch)
GIT_RELEASE_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

