#!/bin/env bash

set -e

# INPUTS

RH_PULL_SECRET='%RH_PULL_SECRET%'

# CHECKS

if [ "$EUID" -eq 0 ]; then 
    echo "Must be ran as a non-root user"
    exit 1
fi

echo "> Installing CodeReady Containers dependencies..."
# NOTE: libgcrypt - upgrade (see: https://github.com/code-ready/crc/issues/1225)
sudo yum install -y NetworkManager qemu-kvm libvirt libgcrypt

echo "> Downloading CodeReady Containers..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz

echo "> Extracting CodeReady Containers..."
tar -xvf crc-linux-amd64.tar.xz crc-linux-1.20.0-amd64/crc

echo "> Installing CodeReady Containers..."
sudo cp crc-linux-1.20.0-amd64/crc /usr/bin/

echo "> Setting up CodeReady Containers..."
crc setup
echo 'export PATH=$PATH:$HOME/.crc/bin/oc' >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "> Starting CodeReady Containers..."
echo $RH_PULL_SECRET > /tmp/pull-secret
crc start -p /tmp/pull-secret
rm /tmp/pull-secret