#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo to execute the script."
  exit 1
fi

echo "Starting Docker installation for Rocky Linux 8.10..."

# Step 1: Set up the Docker repository
echo "Setting up Docker repository..."
cat <<EOF > /etc/yum.repos.d/docker.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/centos/8/x86_64/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF

# Step 2: Install Docker
echo "Installing Docker..."
yum install -y docker-ce docker-ce-cli containerd.io

# Step 3: Start and enable the Docker service
echo "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

# Step 4: Add the current user to the docker group (optional)
echo "Adding current user to the docker group..."
usermod -aG docker $SUDO_USER

# Step 5: Verify Docker installation
echo "Verifying Docker installation..."
docker --version

if [ $? -eq 0 ]; then
  echo "Docker has been successfully installed and is running."
  echo "Log out and log back in to use Docker as a non-root user."
else
  echo "Docker installation failed. Please check the logs above for errors."
fi
