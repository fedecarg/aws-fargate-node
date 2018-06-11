#!/bin/bash

################################################################################

       _NAME_="fargate-deploy.sh"
    _PURPOSE_="This script builds a Docker container and deploys it to \
               Amazon's ECS using the Task Definition and Service entities."
   _REQUIRES_="aws, docker, git, npm"
      _SHELL_="bash"
    _VERSION_="1.0.0"
     _AUTHOR_="Federico Cargnelutti <fedecarg@gmail.com>"

################################################################################


#===============================================================================
# Display usage information
#===============================================================================

usage()
{
    echo "USAGE"
    echo "    ${_NAME_} [OPTIONS]"
    echo ""
    echo "OPTIONS"
    echo "    --env                 <str>    The environment to pass to the container: development or production"
    echo "    --port                <int>    The port number on the container that is bound to the app"
    echo "    --version             <str>    Semantic versioning: mayor, minor or patch"
    echo "    --deploy                       Push image to ECR, and update ECS service to use the new task definition"
    echo "    --help | -h                    Usage information"
    echo ""
    echo "EXAMPLE"
    echo "    $ sh ${_NAME_} --deploy --version minor"
    echo ""
    echo "AWS PROFILE"
    echo "    $ aws configure --profile node-webapp"
    echo "    AWS Access Key ID [None]: <secret>"
    echo "    AWS Secret Access Key [None]: <secret>"
    echo "    Default region name [None]: us-east-1"
    echo "    Default output format [None]: json"
    echo ""
    echo "REQUIRES"
    echo "    ${_REQUIRES_}\n"
}

colour_red()
{
    echo "\033[0;31m${1}\033[0m"
}

colour_green()
{
    echo "\033[0;32m${1}\033[0m"
}


#===============================================================================
# Parse command line options
#===============================================================================

while [ "$1" != "" ]; do
    case $1 in
        --env)              shift; APP_ENV=$1;;
        --port)             shift; APP_PORT=$1;;
        --version)          shift; SEMVER=$1;;
        --deploy)           ECR_DEPLOY_IMAGE=true;;
        --help)             usage; exit;;
        * )                 usage; exit 1
    esac
    shift
done


# Build, tag and push image to repository
ECR_DEPLOY_IMAGE="${ECR_DEPLOY_IMAGE:-false}"

# Semantic version (mayor, minor or patch)
SEMVER="${SEMVER:-patch}"


#===============================================================================
# Load config file
#===============================================================================

# Absolute path to this directory
SCRIPT_DIR=$(cd $(dirname "$0"); pwd)
source $SCRIPT_DIR/fargate-config.sh


#===============================================================================
# Output configuration variables
#===============================================================================

echo "\nDeploy image       : $([ $ECR_DEPLOY_IMAGE == false ] && colour_red $ECR_DEPLOY_IMAGE || colour_green $ECR_DEPLOY_IMAGE)\n"
echo "AWS profile        : $([ -z "${AWS_REGION}" ] && colour_red $AWS_DEFAULT_PROFILE || colour_green $AWS_DEFAULT_PROFILE)"
echo "AWS region         : $(colour_green $AWS_REGION)"
echo "Repository name    : $(colour_green $ECR_NAME)"
echo "Repository uri     : $(colour_green $ECR_URI)"
echo "Docker image       : $(colour_green $ECR_IMAGE)"
echo "Task name          : $(colour_green $ECS_TASK_NAME)"
echo "Service name       : $(colour_green $ECS_SERVICE_NAME)\n"
echo "App root dir       : $(colour_green $APP_PATH)"
echo "App environment    : $(colour_green $APP_ENV)"
echo "App port           : $(colour_green $APP_PORT)\n"
echo "Git release branch : $([ "$GIT_CURRENT_BRANCH" != "$GIT_RELEASE_BRANCH" ] && colour_red $GIT_RELEASE_BRANCH || colour_green $GIT_CURRENT_BRANCH)"
echo "Git revision       : $(colour_green $GIT_REVISION)"
echo "Git username       : $(colour_green $GIT_USER)\n"

if [ -z "$AWS_REGION" ]; then
    echo $(colour_red "error: invalid aws profile: ${AWS_DEFAULT_PROFILE}")
    exit 1
fi

if [ "$GIT_CURRENT_BRANCH" != "$GIT_RELEASE_BRANCH" ]; then
    echo $(colour_red "error: invalid git release branch '${GIT_CURRENT_BRANCH}', expected '${GIT_RELEASE_BRANCH}'")
    exit 1
fi

if [ ! -f "${APP_PATH}/Dockerfile" ]; then
    echo $(colour_red "error: Dockerfile not found in ${APP_PATH}")
    exit 1
fi

if [ "${ECR_DEPLOY_IMAGE}" = false ]; then
    exit 0
fi

cd $APP_PATH


#===============================================================================
# Login to AWS
#===============================================================================

export AWS_DEFAULT_PROFILE

echo $(colour_green "Sending credentials to AWS...")
$(aws ecr get-login --no-include-email --region $AWS_REGION)

[ $? -ne 0 ] && exit 1


#===============================================================================
# Bump version of the Node.js app
#===============================================================================

VERSION=$(npm version $SEMVER)
[ $? -ne 0 ] && exit 1
echo $(colour_green "Version of the app: ${VERSION}")

# Create or update release.json file
printf '{\n\t"version": "%s",\n\t"GIT_CURRENT_BRANCH": "%s",\n\t"git_revision": "%s",\n\t"git_user": "%s"\n}\n}' \
   "$VERSION" \
   "$GIT_CURRENT_BRANCH" \
   "$GIT_REVISION" \
   "$GIT_USER" \
   > release.json 

cat release.json


#===============================================================================
# Build, tag and push a Docker image
#===============================================================================

# Build an image from a Dockerfile
echo $(colour_green "Building Docker image...")
docker build --tag ${ECR_NAME} --build-arg PORT=$APP_PORT --build-arg ENVIRONMENT=$APP_ENV .
[ $? -ne 0 ] && exit 1

# Tag an image referenced by name (ECR_NAME)
echo $(colour_green "Tagging Docker image...")
docker tag $ECR_NAME "${ECR_URI}/${ECR_NAME}:${GIT_REVISION}"

# Push a new image to an ECR registry
echo $(colour_green "Pushing Docker image to ${ECR_URI}/${ECR_NAME}:${GIT_REVISION}...")
docker push "${ECR_URI}/${ECR_NAME}:${GIT_REVISION}"

# Push Git tag
git push origin $VERSION
[ $? -ne 0 ] && exit 1


#===============================================================================
# Register Task Definition
#===============================================================================

# Create ECS container definition
source $SCRIPT_DIR/ecs/task-definition-template.sh

echo $(colour_green "Registering the new task definition...")
aws ecs register-task-definition \
    --region "${AWS_REGION}" \
    --family "${ECS_TASK_NAME}" \
    --requires-compatibilities "FARGATE" \
    --cpu "${ECS_CPU}" \
    --memory "${ECS_MEMORY}" \
    --network-mode "awsvpc" \
    --execution-role-arn "ecsTaskExecutionRole" \
    --container-definitions "${CONTAINER_DEFINITION}"

[ $? -ne 0 ] && exit 1

touch $SCRIPT_DIR/ecs/tasks/task-definition-$GIT_REVISION.json
echo "${TASK_DEFINITION}" > $SCRIPT_DIR/ecs/tasks/task-definition-$GIT_REVISION.json


#===============================================================================
# Update Service
#===============================================================================

echo $(colour_green "Updating the service to use the new task defintion...")
aws ecs update-service \
    --region "${AWS_REGION}" \
    --cluster "${ECS_CLUSTER_NAME}" \
    --service "${ECS_SERVICE_NAME}" \
    --task-definition "${ECS_TASK_NAME}"