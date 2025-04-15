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
    
    # Create .ssh directory and config if they don't exist
    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    
    # Configure SSH to not check host keys for this deployment
    echo -e "Host $host\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null" >> "$HOME/.ssh/config"
    
    # Test SSH connection
    if ! ssh -q -o BatchMode=yes -o ConnectTimeout=5 "$host" exit 2>/dev/null; then
        echo "Error: Could not establish SSH connection to $host"
        return 1
    fi
    
    return 0
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

    # Synchronize files with improved error handling
    echo "Deploying $course to $host..."
    if ! rsync -avz --delete \
        -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
        "dist/$course/" \
        "$user@$host:$path" 2>&1; then
        echo "Error: Failed to deploy $course to $host. Please check SSH connection and permissions."
        continue
    fi

    echo "Successfully deployed $course to $host"
done
