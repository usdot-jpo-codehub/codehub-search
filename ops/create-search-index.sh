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
    "mappings": {
        "logs": {
            "properties": {
                "project_name": {
                    "type": "string",
                      "analyzer": "title_analyzer"
                },
                "project_description": {
                    "type": "string",
                    	"analyzer": "grimdall_analyzer"
                },
                "content": {
                    "type": "string",
                    	"analyzer": "grimdall_analyzer"
                },
                "language": {
                	"type": "string",
                		"analyzer": "language_analyzer"
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
    },
    "settings": {
        "analysis": {
            "analyzer": {
                "title_analyzer": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "char_filter": "my_char",
                    "filter": ["lowercase","my_synonym_filter","edgy"]
                },
                "grimdall_analyzer": {
                	"type": "custom",
                    "tokenizer": "standard",
                    "char_filter": "my_char",
                    "filter": ["lowercase","my_synonym_filter","my_stop","my_snow"]
                },
                "language_analyzer": {
                	"type": "custom",
                    "tokenizer": "standard",
                    "char_filter": "my_char",
                    "filter": ["lowercase","my_synonym_filter","edgy"]
                }
            },
            "filter": {
                "edgy": {
                    "type": "edge_ngram",
                    "min_gram": "2",
                    "max_gram": "10"
                },
                "my_synonym_filter": {
                    "type": "synonym",
					"synonyms": ["javascript=>js"]
                },
                "my_stop": {
                	"type": "stop",
                	"stopwords": "_english_"
                },
                "my_snow": {
                	"type": "snowball",
                	"language": "English"
                }
            },
            "char_filter": {
            	"my_char": {
            		"type": "mapping",
                	"mappings": ["++ => plusplus", "# => sharp"]
                }
            }
        }
    }
}'