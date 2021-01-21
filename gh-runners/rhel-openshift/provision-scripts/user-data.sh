#!/bin/env bash

set -e

echo "> Creating non-root user..."
useradd -G wheel user
echo "demopass" | passwd --stdin user
# allow for PATH to persist
sed -i '/Defaults \+secure_path/s/^/#/' /etc/sudoers
# don't require password
sed -i '0,/%wheel/s/ALL$/NOPASSWD: ALL/' /etc/sudoers