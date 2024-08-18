#!/bin/bash

# Install Docker
sudo yum install docker -y

# Enable Docker service
sudo systemctl enable docker

# Check Docker service status
sudo systemctl status docker

# Start Docker service
sudo systemctl start docker

# Check Docker service status again
sudo systemctl status docker


# Add the ec2-user to the Docker group
sudo usermod -a -G docker ec2-user

# Check Docker version
docker --version

# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make Docker Compose executable
sudo chmod +x /usr/local/bin/docker-compose

# Check Docker Compose version
docker-compose --version
