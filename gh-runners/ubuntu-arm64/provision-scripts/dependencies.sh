#!/bin/bash

set -e

echo "> Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update

echo "> Allowing apt to use a repository over HTTPS..."
sudo apt -yq install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq

echo "> Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "> Installing the stable repository..."
echo \
  "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "> Installing Docker Engine..."
sudo apt update
sudo apt -yq install docker-ce docker-ce-cli containerd.io

echo "> Installing Go..."
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt update
sudo apt -yq install golang-go

echo "> Installing Build Essentials..."
sudo apt -yq install build-essential
