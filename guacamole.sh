#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect the distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot determine the distribution."
    exit 1
fi

# Function to install Docker Compose
install_docker_compose() {
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Log file path
LOG_FILE=~/docker-script-install.log

# Main Installation Logic
echo "Starting Docker Compose installation..." | tee -a $LOG_FILE

# Install Docker Compose
if command_exists docker-compose; then
    echo "Docker Compose is already installed." | tee -a $LOG_FILE
else
    echo "Installing Docker Compose..." | tee -a $LOG_FILE
    install_docker_compose | tee -a $LOG_FILE
fi

# Check Docker Compose version
if command_exists docker-compose; then
    echo "Docker Compose version:" | tee -a $LOG_FILE
    docker-compose --version | tee -a $LOG_FILE
fi

# Create directories and setup Guacamole
if command_exists docker-compose; then
    echo "Setting up Guacamole with docker-compose..." | tee -a $LOG_FILE

    # Create directories for Guacamole setup
    mkdir -p ~/docker/guacamole
    cd ~/docker/guacamole

    # Download the docker-compose.yml file
    echo "Downloading docker-compose.yml..." | tee -a $LOG_FILE
    curl -sSL https://gitlab.com/bmcgonag/docker_installs/-/raw/main/docker_compose_guacamole.yml -o docker-compose.yml

    # Add Docker network (if not already created)
    if ! docker network ls | grep -q my-main-net; then
        echo "Creating Docker network 'my-main-net'..." | tee -a $LOG_FILE
        sudo docker network create my-main-net | tee -a $LOG_FILE
    else
        echo "Network 'my-main-net' already exists." | tee -a $LOG_FILE
    fi

    # Start the services with docker-compose
    echo "Starting Docker Compose services..." | tee -a $LOG_FILE
    sudo docker-compose up -d | tee -a $LOG_FILE
else
    echo "docker-compose is not installed. Please install it and try again." | tee -a $LOG_FILE
    exit 1
fi

echo "Installation completed successfully!" | tee -a $LOG_FILE
