#!/bin/bash
# This script is to do handles the data loading into Elasticsearch

# Start elasticsearch
sudo service elasticsearch start

# Give ES time to start up
sleep 5

# Create mapping for index
curl -XPUT http://$HOST:9200/projects/ -d '{
    "mappings" : {
        "logs" : {
            "properties" : {
                "project_name" : {
                    "type" : "string"
                },
                "project_description" : {
                    "type" : "string"
                },
                "content" : {
                    "type" : "string"
                },
                "contributors_list" : {
                    "type" : "object"
                },
                "suggest" : {
                    "type" : "completion",
                    "analyzer" : "simple",
                    "search_analyzer" : "simple"
                }
            }
        }
    }
}'