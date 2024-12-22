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

# Function to uninstall Docker
uninstall_docker() {
    case $DISTRO in
        ubuntu|debian)
            sudo apt remove -y docker.io
            sudo apt autoremove -y
            ;;
        rocky|rhel|centos)
            sudo yum remove -y docker
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    sudo systemctl stop docker
    sudo systemctl disable docker
}

# Function to install Docker Compose
install_docker_compose() {
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Function to uninstall Docker Compose
uninstall_docker_compose() {
    sudo rm -f /usr/local/bin/docker-compose
}

# Main script logic
echo "Choose an option:"
echo "1. Install Docker and Docker Compose"
echo "2. Uninstall Docker and Docker Compose"
echo "3. Exit"
read -p "Enter your choice [1-3]: " choice

case $choice in
    1)
        # Install Docker
        if command_exists docker; then
            echo "Docker is already installed."
        else
            read -p "Docker is not installed. Do you want to install Docker? (y/n): " install_docker_option
            if [ "$install_docker_option" == "y" ]; then
                install_docker
            else
                echo "Docker installation skipped."
            fi
        fi

        # Install Docker Compose
        if command_exists docker-compose; then
            echo "Docker Compose is already installed."
        else
            read -p "Docker Compose is not installed. Do you want to install Docker Compose? (y/n): " install_compose_option
            if [ "$install_compose_option" == "y" ]; then
                install_docker_compose
            else
                echo "Docker Compose installation skipped."
            fi
        fi
        ;;
    2)
        # Uninstall Docker
        if command_exists docker; then
            read -p "Docker is installed. Do you want to uninstall Docker? (y/n): " uninstall_docker_option
            if [ "$uninstall_docker_option" == "y" ]; then
                uninstall_docker
            else
                echo "Docker uninstallation skipped."
            fi
        else
            echo "Docker is not installed."
        fi

        # Uninstall Docker Compose
        if command_exists docker-compose; then
            read -p "Docker Compose is installed. Do you want to uninstall Docker Compose? (y/n): " uninstall_compose_option
            if [ "$uninstall_compose_option" == "y" ]; then
                uninstall_docker_compose
            else
                echo "Docker Compose uninstallation skipped."
            fi
        else
            echo "Docker Compose is not installed."
        fi
        ;;
    3)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

# Check Docker service status
if command_exists docker; then
    sudo systemctl status docker
fi

# Check Docker and Docker Compose versions
if command_exists docker; then
    docker --version
fi

if command_exists docker-compose; then
    docker-compose --version
fi

# Log file path
LOG_FILE=~/docker-script-install.log

# Check if docker-compose is installed
if command -v docker-compose &>/dev/null; then
    echo "docker-compose is available. Proceeding with the setup..." | tee -a $LOG_FILE
    
    # Create directories
    mkdir -p docker/guacamole | tee -a $LOG_FILE
    cd docker/guacamole
    
    # Download the docker-compose.yml file
    curl https://gitlab.com/bmcgonag/docker_installs/-/raw/main/docker_compose_guacamole.yml \
        -o docker-compose.yml >> $LOG_FILE 2>&1
    
    # Start the services with docker-compose
    sudo docker-compose up -d | tee -a $LOG_FILE
else
    echo "docker-compose is not installed. Please install it and try again." | tee -a $LOG_FILE
    exit 1
fi

