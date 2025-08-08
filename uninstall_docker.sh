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
# Detect Linux Distribution
# -------------------------------
log "Detecting Linux distribution..."
DISTRO=$( (lsb_release -is 2>/dev/null || grep ^NAME= /etc/os-release | cut -d '=' -f2 | tr -d '"') | awk '{print $1}' )

# -------------------------------
# Stop Docker Service
# -------------------------------
log "Stopping Docker service..."
systemctl stop docker
systemctl disable docker
systemctl stop containerd
systemctl disable containerd

# -------------------------------
# Uninstall Docker Packages
# -------------------------------
uninstall_ubuntu_debian() {
  log "Uninstalling Docker packages for $DISTRO..."
  apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker docker.io docker-doc docker-compose
  apt autoremove -y
}

uninstall_rhel() {
  log "Uninstalling Docker packages for $DISTRO..."
  yum remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker docker-client docker-common || dnf remove -y ...
}

case "$DISTRO" in
  Ubuntu|Debian)
    uninstall_ubuntu_debian
    ;;
  RedHatEnterpriseLinux|RedHat|CentOS|Rocky)
    uninstall_rhel
    ;;
  *)
    error "Unsupported distribution: $DISTRO"
    exit 1
    ;;
esac

# -------------------------------
# Remove Docker Files and Directories
# -------------------------------
log "Removing Docker files and directories..."
rm -rf /var/lib/docker /etc/docker /var/run/docker.sock /var/lib/containerd
rm -f /usr/local/bin/docker-compose

# -------------------------------
# Optionally Remove Docker Group from User
# -------------------------------
read -p "Enter the username to remove from the docker group [leave blank to skip]: " DOCKER_USER
if [[ -n "$DOCKER_USER" ]] && id "$DOCKER_USER" &>/dev/null; then
  gpasswd -d "$DOCKER_USER" docker && log "Removed $DOCKER_USER from docker group."
else
  log "No user specified or user does not exist. Skipping group removal."
fi

log "✅ Docker uninstallation complete."
