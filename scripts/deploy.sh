#!/bin/bash

# Read deployment configuration
CONFIG=$(cat deploy-config.json)

# Get list of enabled courses
COURSES=($(echo "$CONFIG" | jq -r 'to_entries | .[] | select(.value.enabled == true) | .key'))

if [ ${#COURSES[@]} -eq 0 ]; then
    echo "No enabled courses found in configuration."
    exit 0
fi

# Function to handle SSH key verification
setup_ssh_key() {
    local host=$1
    local known_hosts="$HOME/.ssh/known_hosts"
    
    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    
    # Remove old key if exists
    ssh-keygen -R "$host" 2>/dev/null
    
    # Add new host key
    ssh-keyscan -H "$host" >> "$known_hosts" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get host key for $host"
        return 1
    fi
}

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

    # Setup SSH key for the host
    echo "Setting up SSH key for $host..."
    if ! setup_ssh_key "$host"; then
        echo "Error: Failed to setup SSH connection for $host. Skipping deployment."
        continue
    fi

    # Synchronize files
    echo "Deploying $course to $host..."
    if ! rsync -avz --checksum --delete \
        "dist/$course/" \
        "$user@$host:$path"; then
        echo "Error: Failed to deploy $course to $host"
        continue
    fi

    echo "Successfully deployed $course to $host"
done
