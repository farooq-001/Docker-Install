#!/bin/bash

# Function to display messages
log() {
  echo -e "\e[1;32m[INFO] $1\e[0m"
}

err() {
  echo -e "\e[1;31m[ERROR] $1\e[0m"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
  err "This script must be run as root."
  exit 1
fi

log "Stopping Docker services..."
systemctl stop docker docker.socket containerd &>/dev/null

log "Disabling Docker services..."
systemctl disable docker docker.socket containerd &>/dev/null

log "Removing Docker packages..."
if command -v dnf &>/dev/null; then
  dnf remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif command -v yum &>/dev/null; then
  yum remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif command -v apt &>/dev/null; then
  apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  apt autoremove -y
else
  err "Unsupported package manager."
  exit 1
fi

log "Removing Docker directories..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -rf /run/docker.sock
rm -rf /etc/systemd/system/docker.service.d
rm -f /etc/systemd/system/docker.service
rm -f /usr/bin/docker*
rm -f /usr/local/bin/docker*

log "Removing all users from docker group..."

# Get all users in 'docker' group
DOCKER_USERS=$(getent group docker | awk -F: '{print $4}' | tr ',' ' ')

# Remove each user from the group
for user in $DOCKER_USERS; do
  if id "$user" &>/dev/null; then
    log " - Removing user '$user' from docker group..."
    gpasswd -d "$user" docker
  fi
done

# Delete the docker group itself
if getent group docker &>/dev/null; then
  log "Deleting 'docker' group..."
  groupdel docker
else
  log "'docker' group does not exist."
fi

log "Docker uninstallation completed successfully."
