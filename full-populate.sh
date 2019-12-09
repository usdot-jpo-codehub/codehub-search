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

echo 'Creating index: Projects'
curl -s -XPUT $HOST/projects/ -H "Content-Type: application/json" -d @/schemas/projects-index.json
echo 'Done creating index: Projects'

echo 'Creating index: Code'
curl -s -XPUT $HOST/code/ -H "Content-Type: application/json" -d @/schemas/code-index.json
echo 'Done creating index: Code'

echo 'Creating index: Repos'
curl -s -XPUT $HOST/repos/ -H "Content-Type: application/json" -d @/schemas/repos-index.json
echo 'Done creating index: Repos'

echo 'Adding data to index: Projects'
elasticdump --input=/data/projects-data.json --output=$ELASTICSEARCH_URL/projects --type=data
echo 'Done adding data to index: Projects'

echo 'Adding data to index: Repos'
elasticdump --input=/data/repos-data.json --output=$ELASTICSEARCH_URL/repos --type=data
echo 'Done adding data to index: Repos'

echo 'Adding data to index: Code'
elasticdump --input=/data/code-data.json --output=$ELASTICSEARCH_URL/code --type=data
echo 'Done adding data to index: Code'