#!/bin/bash

# This script gives an example of how to use the locally-installed elasticsearch-dump 
# to pull data from the repos index and write it to a file called repos-data.json

if [ -z "$ELASTICSEARCH_URL" ]; then
    echo "Error: Required environment variable ELASTICSEARCH_URL not set."
    exit 1
fi

elasticsearch-dump --input=$ELASTICSEARCH_URL/repos --output=repos-data.json --type=data