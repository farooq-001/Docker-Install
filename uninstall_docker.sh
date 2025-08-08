#!/bin/bash

# Custom user to remove from docker group
DOCKER_USER="${1:-${SUDO_USER:-$USER}}"

log() {
  echo -e "\e[1;32m$1\e[0m"
}

# Stop Docker service
log "Stopping Docker service..."
systemctl stop docker
systemctl disable docker

# Remove Docker packages
log "Removing Docker packages..."
if command -v apt &>/dev/null; then
  apt remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif command -v dnf &>/dev/null; then
  dnf remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif command -v yum &>/dev/null; then
  yum remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Remove Docker directories
log "Removing Docker directories..."
rm -rf /var/lib/docker /var/lib/containerd /etc/docker

# Remove Docker user from docker group if exists
if [[ -n "$DOCKER_USER" ]] && id "$DOCKER_USER" &>/dev/null; then
  log "Removing user $DOCKER_USER from docker group..."
  gpasswd -d "$DOCKER_USER" docker
else
  log "User $DOCKER_USER does not exist. Skipping group removal."
fi

# Remove docker group if empty
if getent group docker &>/dev/null; then
  log "Removing docker group..."
  groupdel docker
fi

log "Docker uninstallation completed."
