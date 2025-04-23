#!/bin/bash
set -e

# Set timezone
sudo timedatectl set-timezone Asia/Bangkok

# Update and upgrade system
sudo apt update
sudo apt full-upgrade -y --autoremove

# Install dependencies
sudo apt install -y ca-certificates curl

# Prepare for Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

# Delete old Portainer container if it exists
sudo docker rm -f portainer

# Create Portainer volume and run container
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest

# ...existing code...

echo "Installation complete."
echo "Please log out and log back in to use Docker as your user."
