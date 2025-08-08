#!/bin/bash

# -------------------------------
# Function to display messages
# -------------------------------
log() {
  echo -e "\e[1;32m[INFO] $1\e[0m"
}

error() {
  echo -e "\e[1;31m[ERROR] $1\e[0m"
}

# -------------------------------
# Ensure script is run as root
# -------------------------------
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo."
  exit 1
fi

# -------------------------------
# Detect actual user
# -------------------------------
DOCKER_USER="${SUDO_USER:-$USER}"

# -------------------------------
# STEP 1: Check if Docker & Docker Compose are installed
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
# Detect Linux Distribution
# -------------------------------
log "Detecting Linux distribution..."
if [[ -f /etc/os-release ]]; then
  source /etc/os-release
  DISTRO=$ID
  VERSION_ID=$VERSION_ID
else
  DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
fi

# -------------------------------
# Ubuntu / Debian Install
# -------------------------------
install_ubuntu_debian() {
  log "Installing Docker on Ubuntu/Debian..."

  apt update && apt upgrade -y
  apt remove -y docker docker-engine docker.io containerd runc
  apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  systemctl start docker
  systemctl enable docker

  log "Docker version: $(docker --version)"
  log "Docker Compose version: $(docker compose version | head -n1)"

  usermod -aG docker "$DOCKER_USER"
  log "User '$DOCKER_USER' added to docker group. Please log out and log back in or run 'newgrp docker'."
}

# -------------------------------
# RHEL / Rocky / CentOS 7+ Install
# -------------------------------
install_rhel() {
  log "Installing Docker on RHEL/Rocky/CentOS..."

  yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

  yum install -y yum-utils device-mapper-persistent-data lvm2

  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  systemctl start docker
  systemctl enable docker

  log "Docker version: $(docker --version)"
  log "Docker Compose version: $(docker compose version | head -n1)"

  usermod -aG docker "$DOCKER_USER"
  log "User '$DOCKER_USER' added to docker group. Please log out and log back in or run 'newgrp docker'."
}

# -------------------------------
# Install based on distro
# -------------------------------
case "$DISTRO" in
  ubuntu|debian)
    install_ubuntu_debian
    ;;
  centos|rhel|rocky)
    install_rhel
    ;;
  *)
    error "Unsupported Linux distribution: $DISTRO"
    exit 1
    ;;
esac

log "✅ Docker installation and configuration complete!"
