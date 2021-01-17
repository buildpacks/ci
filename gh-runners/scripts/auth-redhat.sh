#!/usr/bin/env bash

set -e
echo "> Setting 'TF_VAR_RH_USERNAME' variable..."
TF_VAR_RH_USERNAME="$(lpass show --username redhat.com)"
export TF_VAR_RH_USERNAME

echo "> Setting 'TF_VAR_RH_PASSWORD' variable..."
TF_VAR_RH_PASSWORD="$(lpass show --password redhat.com)"
export TF_VAR_RH_PASSWORD

echo "> Setting 'TF_VAR_RH_PULL_SECRET' variable..."
TF_VAR_RH_PULL_SECRET="$(lpass show --note 'Shared-Cloud Native Buildpacks/red-hat-codeready-container-pull-secret')"
export TF_VAR_RH_PULL_SECRET