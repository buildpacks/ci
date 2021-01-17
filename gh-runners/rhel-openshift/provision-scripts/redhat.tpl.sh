#!/bin/env bash

set -e

# INPUTS

RH_USERNAME="%RH_USERNAME%"
RH_PASSWORD="%RH_PASSWORD%"

echo "> Removing previous repos..."
# see https://access.redhat.com/discussions/4222851#comment-1617351
rm -rf /etc/yum.repos.d/*.*

echo "> Registering with RedHat..."
subscription-manager register --username "$RH_USERNAME" --password "$RH_PASSWORD"
subscription-manager role --set="Red Hat Enterprise Linux Server"
subscription-manager usage --set="Test"
subscription-manager service-level --set="Self-Support"
subscription-manager attach
