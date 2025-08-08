#!/bin/bash

# Function to display log messages
log() {
  echo -e "\e[1;33m[INFO] $1\e[0m"
}

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "\e[1;31mThis script must be run as root!\e[0m"
  exit 1
fi

# Define Docker user (can be customized or passed as environment variable)
DOCKER_USER="${DOCKER_USER:-$SUDO_USER}"

# Uninstall Docker packages (Ubuntu/Debian/CentOS/RHEL/Rocky)
log "Attempting to remove Docker packages..."
if command -v apt &>/dev/null; then
  apt remove -y docker docker-engine docker.io containerd runc docker-ce docker-ce-cli docker-compose-plugin
  apt autoremove -y
elif command -v dnf &>/dev/null; then
  dnf remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif command -v yum &>/dev/null; then
  yum remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
  log "Unsupported package manager. Please remove Docker manually."
fi

# Remove user from docker group (if user exists and is in group)
if [[ -n "$DOCKER_USER" ]] && id "$DOCKER_USER" &>/dev/null; then
  if id -nG "$DOCKER_USER" | grep -qw docker; then
    log "Removing user '$DOCKER_USER' from 'docker' group..."
    gpasswd -d "$DOCKER_USER" docker
  else
    log "User '$DOCKER_USER' is not in the 'docker' group."
  fi
else
  log "Docker user is not set or does not exist."
fi

# Remove Docker group if empty
if getent group docker &>/dev/null; then
  log "Removing 'docker' group..."
  groupdel docker
fi

# Remove Docker related files and directories
log "Removing Docker files..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -f /usr/local/bin/docker-compose
rm -f /usr/bin/docker-compose

# Remove Docker repo files
log "Cleaning up Docker repo files..."
rm -f /etc/yum.repos.d/docker*.repo
rm -f /etc/apt/sources.list.d/docker.list
rm -f /usr/share/keyrings/docker-archive-keyring.gpg

log "Docker and related components have been successfully uninstalled!"
