#!/bin/env bash

set -e

echo "> Enable password login..."
sed -i '/PasswordAuthentication \+no/s/no/yes/' /etc/ssh/sshd_config
systemctl restart sshd.service
