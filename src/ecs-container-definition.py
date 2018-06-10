#!/usr/bin/env python

import os 
import sys
import json

containerDefinitions = json.load(sys.stdin)["taskDefinition"]["containerDefinitions"]
containerDefinitions[0]["image"] = os.environ["ECR_IMAGE"]
containerDefinitions[0]["environment"] = [{
	"name": "APP_PORT", 
	"value": os.environ["APP_PORT"]
}, {
	"name": "APP_ENV", 
	"value": os.environ["APP_ENV"]
}, {
	"name": "GIT_BRANCH",
	"value": os.environ["GIT_CURRENT_BRANCH"]
}, {
	"name": "GIT_REVISION",
	"value": os.environ["GIT_REVISION"]
}, {
	"name": "GIT_USER",
	"value": os.environ["GIT_USER"]
}]

print json.dumps(containerDefinitions)