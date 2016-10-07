#!/bin/bash

#
# This script creates the index, doc type, and mappings
#
# ASSUMPTIONS:
# -- Elastic Search is running
# -- Script is executed on the local box
#

SUCCESS=0
ERROR=1
HOST=localhost
PORT=9200
INDEX=projects

# Create mapping for index
curl -XPUT http://$HOST:$PORT/$INDEX/ -d '{
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