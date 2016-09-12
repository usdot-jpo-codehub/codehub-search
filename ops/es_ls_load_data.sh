#!/bin/bash
# This script is to do handles the data loading into Elasticsearch

# Start elasticsearch
sudo service elasticsearch start

# Give ES time to start up
sleep 5

# Create mapping to be used for autocomplete
sudo curl -XPUT http://localhost:9200/projects/ -d '{
    "mappings": {
        "logs": {
            "properties": {
                "project_name": {
                    "type": "string"
                },
                "project_description" : {
                    "type": "string"
                },
                "content": {
                    "type": "string"
                },
                "contributors_list": {
                    "type": "object"
                },
                "componentDependencies": {
                    "type": "object"
                },
                "suggest": {
                    "type": "completion",
                    "analyzer": "simple",
                    "search_analyzer": "simple"
                }
            }
        }
    }
}'

# Run Logstash to index data into Elasticsearch
sudo /opt/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf