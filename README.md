## Overview

The `src/fargate-deploy.sh` bash script allows Node.js developers to deploy high-availability apps to Amazon ECS using Docker, AWS Fargate and the AWS CLI. See PoC: http://fargate.nodejsapp.cloud

The `src/fargate-setup.sh` script can be used to set up a cluster, register a task definition, create a service and perform other common tasks in Amazon ECS with the AWS CLI. Ensure you are using the latest version of the AWS CLI. For more information on how to use AWS Fargate, see [What is Amazon Elastic Container Service?](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)

## Getting started

You're going to need:

* Linux or macOS
* AWS CLI, version 1.15.20 or newer
* Docker, latest version

### Initial setup
**Ubuntu**
Install the AWS CLI using `pip`:
```
sudo apt-get update
sudo apt-get install -qq -y python-pip libpython-dev
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install awscli --upgrade
```
**macOS**
Install the AWS CLI using `brew`:
```
brew install awscli
```

## Build and Provision
1. Clone (or download) this GitHub repo
2. Build your AWS infrastructure using [Terraform](https://www.terraform.io/intro/getting-started/build.html) or [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
3. Provision Docker container

## Usage 
### Usage information
```
$ src/fargate-deploy.sh --help
```

![](https://raw.githubusercontent.com/fedecarg/aws-fargate-node/master/node-webapp-example/public/images/aws-fargate-usage-info.png)

### Dry run deployment
Sometimes deployments are problematic due to bad configuration variables that are un-testable before releasing to dev/test/prod. Having the ability to 'dry run' a deployment and see all the information with specific highlighting for variables allows the identification of changes that need to be made before actually deploying to an environment.

Not passing the `--deploy` option to `src/fargate-deploy.sh` causes the script to print config variabes needed to build and deploy a Docker image to an environment:
```
$ src/fargate-deploy.sh --env dev --port 3000 --version minor
```

### Deployment 
```
$ src/fargate-deploy.sh --env dev --port 3000 --version minor --deploy
```
![](https://raw.githubusercontent.com/fedecarg/aws-fargate-node/master/node-webapp-example/public/images/aws-fargate-deploy.png)
