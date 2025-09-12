#!/bin/bash
# Installs Docker Engine & Docker Compose plugin on Ubuntu 24.04 LTS
# and configures current user to run docker without sudo.

set -euo pipefail

echo "=== Removing any old Docker versions ==="
sudo apt remove -y docker docker-engine docker.io containerd runc || true

echo "=== Updating system and installing prerequisites ==="
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "=== Adding Docker’s official GPG key ==="
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "=== Adding Docker’s APT repository ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Installing Docker Engine, CLI and Compose plugin ==="
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Adding current user ($USER) to docker group ==="
sudo usermod -aG docker "$USER"

echo "=== Checking Docker versions ==="
docker --version
docker compose version

echo "=== Running hello-world container to test ==="
sudo systemctl enable --now docker
docker run --rm hello-world || echo "hello-world test failed — log out/in first to apply group changes."

echo "=== Done. Log out/in or run 'newgrp docker' if you still need sudo for docker. ==="
