#!/bin/bash

# Detect the OS distribution
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')

echo "Detected OS: $OS"

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
    echo "Installing Docker on Ubuntu..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://get.docker.com | sudo sh
    sudo systemctl enable docker
    sudo systemctl start docker
}

# Function to install Docker on CentOS, Rocky Linux, or RHEL
install_docker_centos_rocky_rhel() {
    echo "Installing Docker on CentOS/Rocky Linux/RHEL..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker
}

# Install Docker based on the detected OS
case "$OS" in
    *Ubuntu*)
        install_docker_ubuntu
        ;;
    *CentOS*|*Rocky*|*RHEL*)
        install_docker_centos_rocky_rhel
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "Docker installation complete!"

# Verify Docker installation
docker --version
