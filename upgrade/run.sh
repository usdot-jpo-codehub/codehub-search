#!/bin/bash

HOST=localhost
PORT=9200

#Build docker image
docker build -t codehub-search:2.0 .

#Create container and run
docker-compose up -d

#Wait ES to start
echo 'Waiting ES to start'
sleep 15
echo 'done'

#Create Index: Projects
echo 'Create index: Projects'
curl -s -XPUT http://$HOST:$PORT/projects/ -H "Content-Type: application/json" -d @projects-index.json
echo
echo 'Create index: Code'
#Create Index: Code
curl -s -XPUT http://$HOST:$PORT/code/ -H "Content-Type: application/json" -d @code-index.json

echo 'end'