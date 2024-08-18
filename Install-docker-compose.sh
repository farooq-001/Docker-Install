#!/bin/bash

# Detect the distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot determine the distribution."
    exit 1
fi

# Function to install Docker
install_docker() {
    case $DISTRO in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y docker.io
            sudo systemctl enable docker
            sudo systemctl start docker
            ;;
        rocky|rhel|centos)
            sudo yum install -y docker
            sudo systemctl enable docker
            sudo systemctl start docker
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Install Docker
install_docker

# Check Docker service status
sudo systemctl status docker

# Add the current user to the Docker group
sudo usermod -aG docker $(whoami)

# Check Docker version
docker --version

# Download Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make Docker Compose executable
sudo chmod +x /usr/local/bin/docker-compose

# Check Docker Compose version
docker-compose --version
