#!/bin/bash

# -------------------------------
# Utility Functions
# -------------------------------
log() {
  echo -e "\e[1;32m[INFO] $1\e[0m"
}
error() {
  echo -e "\e[1;31m[ERROR] $1\e[0m"
}

# -------------------------------
# Root Privilege Check
# -------------------------------
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo."
  exit 1
fi

# -------------------------------
# Check if Docker & Docker Compose are already installed
# -------------------------------
if command -v docker &>/dev/null && (docker compose version &>/dev/null || docker-compose --version &>/dev/null); then
  log "✅ Docker and Docker Compose are already installed."
  docker --version
  if docker compose version &>/dev/null; then
    docker compose version
  else
    docker-compose --version
  fi
  exit 0
else
  log "Docker or Docker Compose not found. Proceeding with installation..."
fi

# -------------------------------
# Ask for custom user to add to docker group
# -------------------------------
read -p "Enter the username to add to the docker group [default: ${SUDO_USER:-$USER}]: " CUSTOM_USER
DOCKER_USER="${CUSTOM_USER:-${SUDO_USER:-$USER}}"

if id "$DOCKER_USER" &>/dev/null; then
  log "Using user: $DOCKER_USER"
else
  error "User '$DOCKER_USER' does not exist. Please create the user before running this script."
  exit 1
fi

# -------------------------------
# Docker Installation Config
# -------------------------------
DOCKER_GPG_KEY_URL="https://download.docker.com/linux/ubuntu/gpg"
DOCKER_REPO_UBUNTU="deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
DOCKER_REPO_RHEL="https://download.docker.com/linux/centos/docker-ce.repo"
DOCKER_VERSION="docker-ce docker-ce-cli containerd.io docker-compose-plugin"

# -------------------------------
# Detect Linux Distribution
# -------------------------------
log "Detecting Linux distribution..."
DISTRO=$( (lsb_release -is 2>/dev/null || grep ^NAME= /etc/os-release | cut -d '=' -f2 | tr -d '"') | awk '{print $1}' )

# -------------------------------
# Install Docker for Ubuntu/Debian
# -------------------------------
install_ubuntu_debian() {
  log "Updating system..."
  apt update && apt upgrade -y

  log "Removing old Docker versions (if any)..."
  apt remove -y docker docker-engine docker.io containerd runc

  log "Installing prerequisites..."
  apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg

  log "Adding Docker’s official GPG key..."
  curl -fsSL "$DOCKER_GPG_KEY_URL" | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  log "Setting up Docker repository..."
  echo "$DOCKER_REPO_UBUNTU" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  log "Installing Docker Engine and Docker Compose plugin..."
  apt update
  apt install -y $DOCKER_VERSION

  log "Enabling and starting Docker service..."
  systemctl enable docker
  systemctl start docker

  log "Verifying Docker installation..."
  docker --version
  docker compose version

  log "Adding user '$DOCKER_USER' to docker group..."
  usermod -aG docker "$DOCKER_USER"
  log "Please log out and log back in or run 'newgrp docker' to apply the group change."
}

# -------------------------------
# Install Docker for RHEL/CentOS/Rocky
# -------------------------------
install_rhel() {
  log "Updating system..."
  yum update -y || dnf update -y

  log "Installing required packages..."
  yum install -y yum-utils || dnf install -y dnf-utils

  log "Adding Docker repository..."
  yum-config-manager --add-repo "$DOCKER_REPO_RHEL" || dnf config-manager --add-repo "$DOCKER_REPO_RHEL"

  log "Installing Docker..."
  yum install -y $DOCKER_VERSION || dnf install -y $DOCKER_VERSION

  log "Enabling and starting Docker service..."
  systemctl enable docker
  systemctl start docker

  log "Verifying Docker installation..."
  docker --version
  docker compose version

  log "Adding user '$DOCKER_USER' to docker group..."
  usermod -aG docker "$DOCKER_USER"
  log "Please log out and log back in or run 'newgrp docker' to apply the group change."
}

# -------------------------------
# Main Installer Logic
# -------------------------------
case "$DISTRO" in
  Ubuntu|Debian)
    log "Detected distribution: $DISTRO"
    install_ubuntu_debian
    ;;
  RedHatEnterpriseLinux|RedHat|CentOS|Rocky)
    log "Detected distribution: $DISTRO"
    install_rhel
    ;;
  *)
    error "Unsupported distribution: $DISTRO"
    exit 1
    ;;
esac

log "✅ Docker & Docker Compose installation completed successfully."
