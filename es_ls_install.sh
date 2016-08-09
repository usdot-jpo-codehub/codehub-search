#!/bin/bash
# This script is to install Elasticsearch and Logstash on the AWS EC2 for heimdall-search

# Elasticsearch installation
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

echo '[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1' | sudo tee /etc/yum.repos.d/elasticsearch.repo

sudo yum -y install elasticsearch

sudo sed -i '54s/.*/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
# sudo echo 'network.host: 0.0.0.0' >> /etc/elasticsearch/elasticsearch.yml

# Logstash installation
echo '[logstash-2.3]
name=Logstash repository for 2.3.x packages
baseurl=https://packages.elastic.co/logstash/2.3/centos
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1' | sudo tee /etc/yum.repos.d/logstash.repo

sudo yum -y install logstash

