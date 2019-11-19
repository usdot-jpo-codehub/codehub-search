#!/bin/bash
docker run -d -p 9200:9200 --name codehub-elasticsearch elasticsearch:7.4.1
echo "ElasticSearch Docker container running on localhost:9200."