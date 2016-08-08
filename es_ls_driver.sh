#!/bin/bash
# This script is the driver for all the scripts needed to install, configure, and load data into ES and LS
clear

# Run the installation script
echo "Running the installation script for Logstash and Elasticsearch..."
sh ./es_ls_install.sh
echo "Installation complete."

# Run the configuration script
echo "Running the configuration script for Logstash and Elasticsearch..."
sh ./es_ls_config.sh
echo "Configuration complete."

# Run the data load script
echo "Running the data load script for Logstash and Elasticsearch..."
sh ./es_ls_load_data.sh
echo "Data load complete."