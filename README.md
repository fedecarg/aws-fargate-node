# Overview

The `src/fargate-deploy.sh` allows Node.js developers to deploy high-availability apps to Amazon ECS using Docker, AWS Fargate and the AWS CLI.

http://fargate.nodejsapp.cloud

The The `src/fargate-setup.sh` script helps you set up a cluster, register a task definition, create a service and perform other common scenarios in Amazon ECS with the AWS CLI. Ensure you are using the latest version of the AWS CLI. For more information on how to use AWS Fargate, see [What is Amazon Elastic Container Service?](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)

Prerequisites

Step 1: Create a Cluster
Step 2: Register a Task Definition
Step 3: List Task Definitions
Step 4: Create a Service
Step 5: List Services
Step 6: Describe the Running Service

 allows Node.js developers  using  and AWS Fargate 

# Usage information
```
$ src/fargate-deploy.sh --help
```

![](https://raw.githubusercontent.com/fedecarg/aws-fargate-node/master/node-webapp-example/public/images/aws-fargate-usage-info.png)

# Deploy Node.js app

```
$ src/fargate-deploy.sh --env dev --port 3000 --version minor --deploy
```

![](https://raw.githubusercontent.com/fedecarg/aws-fargate-node/master/node-webapp-example/public/images/aws-fargate-deploy.png)
