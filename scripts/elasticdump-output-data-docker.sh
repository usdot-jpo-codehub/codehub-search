#!/bin/bash

# This script gives an example of how to use the Dockerized elasticsearch-dump 
# to pull data from the repos index and write it to a file called repos-data.json

# Note: Swap the --input and --output destinations to upload data from repos-data.json into the ES repos index

# Note: There are two important differences in this script: 
# 1. It uses Docker
# 2. It mounts the current directory into the container to provide the data locally.

if [ -z "$ELASTICSEARCH_URL" ]; then
    echo "Error: Required environment variable ELASTICSEARCH_URL not set."
    exit 1
fi

docker run --rm -ti -v $PWD:/tmp taskrabbit/elasticsearch-dump --input=$ELASTICSEARCH_URL/repos --output=repos-data.json --type=data