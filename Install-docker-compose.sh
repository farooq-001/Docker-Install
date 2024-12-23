#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install Docker Compose
install_docker_compose() {
    echo "Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
    if [ -z "$DOCKER_COMPOSE_VERSION" ]; then
        echo "Failed to retrieve Docker Compose version."
        exit 1
    fi
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || { echo "Failed to download Docker Compose."; exit 1; }
    sudo chmod +x /usr/local/bin/docker-compose || { echo "Failed to set permissions for Docker Compose."; exit 1; }
    echo "Docker Compose installed successfully."
}

# Check if Docker is installed and `docker --version` is available
if command_exists docker && docker --version &> /dev/null; then
    echo "Docker is installed. Proceeding to install Docker Compose."
else
    echo "Docker is not installed or not available. Please install Docker first before running this script."
    exit 1
fi

# Check if Docker Compose is already installed
if command_exists docker-compose; then
    echo "Docker Compose is already installed."
    docker-compose --version
else
    install_docker_compose
    echo "Docker Compose version:"
    docker-compose --version
fi
