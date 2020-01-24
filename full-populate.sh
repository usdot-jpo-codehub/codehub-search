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

echo 'Creating index: Repositories'
curl -s -XPUT $HOST/repositories/ -H "Content-Type: application/json" -d @/schemas/repositories-index.json
echo 'Done creating index: repositories'

echo 'Adding data to index: Repositories'
elasticdump --input=/data/repositories-data.json --output=$ELASTICSEARCH_URL/repositories --type=data
echo 'Done adding data to index: Repositories'

echo 'Creating index: Related'
curl -s -XPUT $HOST/related/ -H "Content-Type: application/json" -d @/schemas/related-index.json
echo 'Done creating index: Related'

echo 'Adding data to index: Related'
elasticdump --input=/data/related-data.json --output=$ELASTICSEARCH_URL/related --type=data
echo 'Done adding data to index: Related'
