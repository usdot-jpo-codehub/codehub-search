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
TYPE=project

STATUS=$(curl -so /dev/null -w '%{response_code}' http://$HOST:$PORT/$INDEX)

if [ "$STATUS" -eq 200 ]; then
   echo "Index exists ... Updating Index Mappings and Settings"
   curl -X POST http://localhost:9200/$INDEX/_close
   curl -X PUT http://localhost:9200/$INDEX/_settings -d '{
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
               "min_gram": "5",
               "max_gram": "15"
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
 }'
 curl -X POST http://localhost:9200/$INDEX/_open
 curl -X PUT http://localhost:9200/$INDEX/$TYPE/_mapping?ignore_conflicts=true -d '{
   "project" : {
        "properties" : {
          "commits" : {
            "type" : "long"
          },
          "contributors" : {
            "type" : "long"
          },
          "contributors_list" : {
            "properties" : {
              "avatar_url" : {
                "type" : "string"
              },
              "profile_url" : {
                "type" : "string"
              },
              "user_type" : {
                "type" : "string"
              },
              "username" : {
                "type" : "string"
              }
            }
          },
          "forks" : {
            "type" : "string"
          },
          "full_name" : {
            "type" : "string"
          },
          "id" : {
            "type" : "string"
          },
          "language" : {
            "type" : "string",
            "analyzer" : "language_analyzer"
          },
          "languages" : {
            "type" : "string"
          },
          "organization" : {
            "properties" : {
              "org_avatar_url" : {
                "type" : "string"
              },
              "org_type" : {
                "type" : "string"
              },
              "organization" : {
                "type" : "string"
              },
              "organization_url" : {
                "type" : "string"
              }
            }
          },
          "origin" : {
            "type" : "string"
          },
          "project_description" : {
            "type" : "string",
            "analyzer" : "grimdall_analyzer"
          },
          "project_name" : {
            "type" : "string",
            "analyzer" : "title_analyzer"
          },
          "rank" : {
            "type" : "long"
          },
          "readMe" : {
            "properties" : {
              "content" : {
                "type" : "string"
              },
              "url" : {
                "type" : "string"
              }
            }
          },
          "releases" : {
            "type" : "long"
          },
          "repository" : {
            "type" : "string"
          },
          "repository_url" : {
            "type" : "string"
          },
          "stage_source" : {
            "type" : "string"
          },
          "stars" : {
            "type" : "string"
          },
          "suggest" : {
            "type" : "completion",
            "analyzer" : "simple",
            "payloads" : false,
            "preserve_separators" : true,
            "preserve_position_increments" : true,
            "max_input_length" : 50
          },
          "updated_at" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "watchers" : {
            "type" : "long"
          }
        }
      }
 }'

elif [ "$STATUS" -eq 404 ]; then
   echo "Index doesn't exist...Creating new index with Mappings and Settings"
   # Create mapping for index
   curl -XPUT http://$HOST:$PORT/$INDEX/ -d '{
   "mappings": {
       "project": {
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
else
   echo "please check whether the server is up...."
fi

