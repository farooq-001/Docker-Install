#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if Homebrew is installed, and install if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Docker Desktop for Mac (assuming Docker Desktop is the preferred way for macOS)
echo "Installing Docker Desktop for Mac..."
brew install --cask docker

# Check Docker version
echo "Checking Docker version..."
docker --version

# Install Docker Compose via Homebrew
echo "Installing Docker Compose..."
brew install docker-compose

# Check Docker Compose version
echo "Checking Docker Compose version..."
docker-compose --version

echo "Docker and Docker Compose installation completed successfully."
