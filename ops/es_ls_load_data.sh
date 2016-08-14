#!/bin/bash
# This script is to do handles the data loading into Elasticsearch

# Start elasticsearch
sudo service elasticsearch start

# Give ES time to start up
sleep 5

# Create an index on which to apply a mapping
sudo curl -XPUT 'localhost:9200/projects'

# Create mapping to be used for autocomplete
sudo curl -XPUT 'localhost:9200/projects/logs/_mapping' -d '{
"logs" : {
"properties" : {
"project_name" : { "type" : "string" },
"project_description" : { "type" : "string" },
"content" : { "type" : "string" },
"suggest" : { "type" : "completion",
"analyzer" : "simple",
"search_analyzer" : "simple"
}
}
}
}'

# Run Logstash to index data into Elasticsearch
sudo /opt/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf