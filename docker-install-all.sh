#!/bin/bash

# Function to fix the GPG error for Brave repository
fix_brave_gpg_error() {
    echo "Fixing GPG error for Brave repository..."
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0686B78420038257
}

# Function to remove Brave repository if it's not needed
remove_brave_repo() {
    echo "Removing Brave repository (if not needed)..."
    sudo add-apt-repository --remove ppa:brave-browser/stable
    sudo apt-get update
}

# Function to install Docker on Ubuntu
install_docker() {
    echo "Starting Docker installation..."

    # Remove any existing Docker installations
    sudo apt-get remove -y docker docker-engine docker.io containerd runc

    # Update apt package index
    sudo apt-get update

    # Install required dependencies
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update apt package index again
    sudo apt-get update

    # Install Docker Engine
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Start Docker and enable it to run at boot
    sudo systemctl enable docker
    sudo systemctl start docker

    # Verify Docker installation
    docker --version
}

# Main script execution
echo "Starting installation process..."

# Fix Brave GPG error if necessary
fix_brave_gpg_error

# Optionally, remove Brave repository if not needed
# Uncomment the line below if you want to remove the Brave repository
# remove_brave_repo

# Install Docker
install_docker

echo "Docker installation complete!"
