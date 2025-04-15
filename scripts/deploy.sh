#!/bin/bash

# Read deployment configuration
CONFIG=$(cat deploy-config.json)
COURSES=("SRE")

for course in "${COURSES[@]}"; do
    # Parse configuration
    host=$(echo "$CONFIG" | jq -r ".${course}.host")
    user=$(echo "$CONFIG" | jq -r ".${course}.user")
    path=$(echo "$CONFIG" | jq -r ".${course}.path")

    # Check if the directory exists
    if [ ! -d "dist/$course/" ]; then
        echo "Warning: Directory dist/$course/ does not exist. Skipping deployment for $course."
        continue
    fi

    # Synchronize files
    echo "Deploying $course to $host..."
    rsync -avz --delete \
        "dist/$course/" \
        "$user@$host:$path"
done
