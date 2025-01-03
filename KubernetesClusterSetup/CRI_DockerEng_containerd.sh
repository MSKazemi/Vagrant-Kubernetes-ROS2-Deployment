#!/bin/bash
# set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
sudo usermod -aG docker vagrant
newgrp docker


# containerd 
CONFIG_FILE="/etc/containerd/config.toml"
# Backup the original config file
sudo mv $CONFIG_FILE "${CONFIG_FILE}.backup"

sudo containerd config default > temp.toml
sed -i '/\[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc\]/,/^\[/{s/SystemdCgroup = false/SystemdCgroup = true/}' temp.toml

sudo cp temp.toml ${CONFIG_FILE}

sudo systemctl restart containerd