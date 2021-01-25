#!/bin/env bash

set -e

echo "> Enable password login..."
sed -i '/PasswordAuthentication \+no/s/no/yes/' /etc/ssh/sshd_config
systemctl restart sshd.service

echo "> Creating non-root user..."
# NOTE: user should NOT have a password so that they may not login via SSH
useradd -G wheel user
# allow for PATH to persist
sed -i '/Defaults \+secure_path/s/^/#/' /etc/sudoers
# don't require password
sed -i '0,/%wheel/s/ALL$/NOPASSWD: ALL/' /etc/sudoers