#!/bin/bash

HOST=localhost
PORT=9200

STATUS=$(curl -so /dev/null -w '%{response_code}' http://$HOST:$PORT/projects)

if [ "$STATUS" -eq 200 ]; then
  echo 'Inserting data to index: Projects'
  curl -s -XPUT http://$HOST:$PORT/projects/_bulk -H "Content-Type: application/x-ndjson" --data-binary @projects-sampledata-bulkinsert.txt
else
  echo 'Error: Index Projects not found.'
fi


STATUS=$(curl -so /dev/null -w '%{response_code}' http://$HOST:$PORT/code)

if [ "$STATUS" -eq 200 ]; then
  echo 'Inserting data to index: code'
  curl -s -XPUT http://$HOST:$PORT/code/_bulk -H "Content-Type: application/x-ndjson" --data-binary @code-sampledata-bulkinsert.txt
else
  echo 'Error: Index Code not found.'
fi
echo
echo 'end'