#!/bin/bash

# Script cannot be run multiple times since the name is already taken.  You can either remove the container or change
# the name.

docker run -d -p 9200:9200 --name stage-search stage/search:0.1.0