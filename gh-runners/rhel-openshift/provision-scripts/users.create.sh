#!/bin/env bash

set -e

# INPUTS

while getopts u:p: flag; do
    case "${flag}" in
        u) USERNAME=${OPTARG};;
        p) PASSWORD=${OPTARG};;
    esac
done

echo "> Creating non-root user..."
useradd -G wheel "${USERNAME}"
echo "${PASSWORD}" | passwd --stdin "${USERNAME}"
# allow for PATH to persist
sed -i '/Defaults \+secure_path/s/^/#/' /etc/sudoers
# don't require password
sed -i '0,/%wheel/s/ALL$/NOPASSWD: ALL/' /etc/sudoers