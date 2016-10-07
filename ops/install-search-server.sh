#!/bin/bash

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

