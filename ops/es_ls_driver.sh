#!/bin/bash
# This script is the driver for all the scripts needed to install, configure, and load data into ES and LS
clear

# Run the installation script
echo "Running the installation script for Logstash and Elasticsearch..."
sh ./es_ls_install.sh
echo "Installation complete."

# Run the data load script
echo "Running Search Schema (Index, Document, Mapping) scripts..."
sh ./es_create_schemas.sh
echo "Schema Creation complete."