#!/bin/bash
# This script is the driver for all the scripts needed to install, configure, and start ElasticSearch
#
# ASSUMPTIONS:
# -- Scripts are all executed on the local machine where installation is to take place.
#

clear

echo "Installing ElasticSearch..."
./install-search-server.sh
echo "ElasticSearch nstallation complete."

echo "Creating index..."
./create-search-index.sh
echo "Index creation complete."

echo "Starting ElasticSearch..."
./start-search-server.sh
echo "ElasticSearch started"