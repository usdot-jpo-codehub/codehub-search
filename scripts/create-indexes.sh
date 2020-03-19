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

# Create Index: Repositories
echo 'Creating index: Repositories'
curl -s -XPUT $HOST/repositories/ -H "Content-Type: application/json" -d @../schemas/repositories-index.json
echo
echo 'end'

# Create Index: Related
echo 'Creating index: Related'
curl -s -XPUT $HOST/related/ -H "Content-Type: application/json" -d @../schemas/releated-index.json
echo
echo 'end'

# Create Index: Configurations
echo 'Creating index: Configurations'
curl -s -XPUT $HOST/configurations/ -H "Content-Type: application/json" -d @../schemas/configurations-index.json
echo
echo 'end'
