#!/bin/bash

# -------------------------------
# Logger Function
# -------------------------------
log() {
  echo -e "\e[1;32m[INFO] $1\e[0m"
}
error() {
  echo -e "\e[1;31m[ERROR] $1\e[0m"
}

# -------------------------------
# Root Check
# -------------------------------
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo privileges."
  exit 1
fi

# -------------------------------
# User Detection
# -------------------------------
DOCKER_USER=$(logname 2>/dev/null || echo root)

# Validate user existence
if ! id "$DOCKER_USER" &>/dev/null; then
  error "User '$DOCKER_USER' does not exist. Please create the user before running this script."
  exit 1
fi

# -------------------------------
# Docker & Docker Compose Check
# -------------------------------
if command -v docker &>/dev/null && command -v docker-compose &>/dev/null; then
  log "Docker and Docker Compose are already installed:"
  docker --version
  docker-compose --version
  exit 0
else
  log "Docker or Docker Compose not found. Proceeding with installation..."
fi

# -------------------------------
# Dynamic Distribution Detection
# -------------------------------
DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')
VERSION_ID=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release | tr -d '"')
DOCKER_VERSION="docker-ce docker-ce-cli containerd.io docker-compose-plugin"

# -------------------------------
# Ubuntu / Debian Installation
# -------------------------------
install_ubuntu_debian() {
  log "Installing Docker on Ubuntu/Debian..."

  apt update && apt upgrade -y
  apt remove -y docker docker-engine docker.io containerd runc

  apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt update
  apt install -y $DOCKER_VERSION

  systemctl enable docker
  systemctl start docker

  log "Docker installed successfully."
}

# -------------------------------
# CentOS 7 / RHEL 7+ Installation
# -------------------------------
install_centos_rhel() {
  log "Installing Docker on CentOS/RHEL/Rocky..."

  yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

  yum install -y yum-utils device-mapper-persistent-data lvm2 curl

  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  yum install -y $DOCKER_VERSION

  systemctl enable docker
  systemctl start docker

  log "Docker installed successfully."
}

# -------------------------------
# Install Docker Based on Distro
# -------------------------------
case "$DISTRO" in
  ubuntu|debian)
    install_ubuntu_debian
    ;;
  centos|rhel|rocky)
    install_centos_rhel
    ;;
  *)
    error "Unsupported distribution: $DISTRO"
    exit 1
    ;;
esac

# -------------------------------
# Post Install Configuration
# -------------------------------
log "Adding user '$DOCKER_USER' to docker group..."
usermod -aG docker "$DOCKER_USER"

log "Verifying Docker installation..."
docker --version || error "Docker installation failed"
docker compose version || log "Docker Compose plugin not available"

log "Docker installation completed successfully for user '$DOCKER_USER'."
