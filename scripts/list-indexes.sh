#!/bin/bash

if [ -z "$ELASTICSEARCH_URL" ]; then
    echo "Error: Required environment variable ELASTICSEARCH_URL not set."
    exit 1
fi

curl $ELASTICSEARCH_URL/_cat/indices?v