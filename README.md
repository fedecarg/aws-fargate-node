# Overview

The `src/fargate-deploy.sh` bash script allows Node.js developers to deploy high-availability apps to Amazon ECS using Docker, AWS Fargate and the AWS CLI. See PoC: http://fargate.nodejsapp.cloud

The `src/fargate-setup.sh` script can be used to set up a cluster, register a task definition, create a service and perform other common tasks in Amazon ECS with the AWS CLI. Ensure you are using the latest version of the AWS CLI. For more information on how to use AWS Fargate, see [What is Amazon Elastic Container Service?](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)

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
