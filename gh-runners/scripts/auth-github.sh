#!/usr/bin/env bash

set -e

echo "> Setting 'TF_VAR_GH_TOKEN' variable..."
TF_VAR_GH_TOKEN="$(lpass show --note 'Shared-Cloud Native Buildpacks/buildpack-github-release-token')"
export TF_VAR_GH_TOKEN