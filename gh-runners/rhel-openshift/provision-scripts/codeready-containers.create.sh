#!/bin/env bash
set -x
set -e

# CHECKS

if [ "$EUID" -eq 0 ]; then 
    echo "Must be ran as a non-root user"
    exit 1
fi

# INPUTS

while getopts p:v: flag; do
    case "${flag}" in
        p) RH_PULL_SECRET=${OPTARG};;
        v) RH_CRC_VERSION=${OPTARG};;
    esac
done

echo "> Installing CodeReady Containers dependencies..."
# NOTE: libgcrypt - upgrade (see: https://github.com/code-ready/crc/issues/1225)
sudo yum install -y NetworkManager qemu-kvm libvirt libgcrypt

echo "> Downloading CodeReady Containers..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/crc/${RH_CRC_VERSION}/crc-linux-amd64.tar.xz -O crc-${RH_CRC_VERSION}.tar.xz

echo "> Extracting CodeReady Containers..."
tar --strip-components=1 -xvf crc-${RH_CRC_VERSION}.tar.xz --wildcards --no-anchored 'crc'

echo "> Installing CodeReady Containers..."
sudo mv crc /usr/bin/crc

echo "> Setting up CodeReady Containers..."
crc config set consent-telemetry no
crc setup
echo 'export PATH=$PATH:$HOME/.crc/bin/oc' >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "> Starting CodeReady Containers..."
echo $RH_PULL_SECRET > /tmp/pull-secret
crc start -p /tmp/pull-secret

echo "> Cleaning up..."
rm -f /tmp/pull-secret
