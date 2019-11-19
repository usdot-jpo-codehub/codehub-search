#!/bin/bash

if [ -z "$ELASTICSEARCH_URL" ]; then
    echo "Error: Required environment variable ELASTICSEARCH_URL not set."
    exit 1
fi

HOST=$ELASTICSEARCH_URL

STATUS=$(curl -so /dev/null -w '%{response_code}' $HOST)
if [ "$STATUS" -ne 200 ]; then
  echo 'Error: Connection to ES failed.'
  exit 1
fi

# Create Index: Projects
echo 'Creating index: Projects'
curl -s -XPUT $HOST/projects/ -H "Content-Type: application/json" -d @../schemas/projects-index.json
echo

echo 'Creating index: Code'
# Create Index: Code
curl -s -XPUT $HOST/code/ -H "Content-Type: application/json" -d @../schemas/code-index.json
echo
echo 'end'

echo 'Creating index: Repos'
# Create Index: Code
curl -s -XPUT $HOST/repos/ -H "Content-Type: application/json" -d @../schemas/repos-index.json
echo
echo 'end'