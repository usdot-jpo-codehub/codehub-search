#!/bin/bash
# This script is to configure Elasticsearch and Logstash on the AWS EC2 for heimdall-search

# Replace network host with localhost for security reasons
sudo sed -i '54s/.*/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml

# Copy logstash config file to proper directory
sudo cp /opt/heimdall/logstash.conf /etc/logstash/conf.d/