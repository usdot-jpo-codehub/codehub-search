#!/bin/bash

npm install js-yaml -g
npm install js-yaml
npm install elasticdump -g
elasticdump --version
node process_appspec.js $(aws ecs list-task-definitions --region us-east-1 --family-prefix codehub-search | jq -r ".taskDefinitionArns[-1]")
aws s3 cp appspec.yaml s3://codehub-dev-search
aws deploy wait deployment-successful --region us-east-1 --deployment-id $(aws deploy create-deployment --cli-input-json file://codehub-search-create-deployment.json --region us-east-1 | jq -r ".deploymentId")
aws s3 sync s3://codehub-dev-data-update .
ls -l
./create-search-index.sh
elasticdump --input=projects_data.json --output=http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects --type=data
elasticdump --input=code_data.json --output=http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code --type=data
echo Successfull Deployment Confirmed!!
echo Updated ES Indices are Updated!!
echo ES Updated With Latest Data!!
