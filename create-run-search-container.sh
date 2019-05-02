#!/bin/bash

# Script cannot be run multiple times since the name is already taken.  You can either remove the container or change
# the name.

docker run -d -p 9200:9200 --name codehub-search dev-codehub/codehub-search:latest
