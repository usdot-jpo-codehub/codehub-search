#!/bin/bash
echo "Building elasticsearch image..."
./build.sh
echo "Starting elasticsearch container..."
./run.sh