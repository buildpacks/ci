#!/usr/bin/env bash

if [[ -z $1 ]]; then
  echo "USAGE: set-pipeline.sh <pipeline-name>"
  exit 1
fi

pipeline=$1

lpass_note() {
  lpass show --notes "Shared-Cloud Native Buildpacks/$1"
}

dir="$(cd "$(dirname "$0")" && pwd)"

concourse_service_account_key=$(lpass_note 'cncf-concourse-service-account-json-key')
buildpack_github_release_token=$(lpass_note 'buildpack-github-release-token')
cnbs_dockerhub_password=$(lpass_note 'cnbs-dockerhub-password')

cat <(cat "$dir/pipelines/$pipeline/resources.yml" && echo "" && cat "$dir/pipelines/$pipeline/jobs.yml") | pbcopy

fly -t buildpacksio set-pipeline \
  -p "$pipeline" \
  --var concourse-service-account-key-json="$concourse_service_account_key" \
  --var buildpack-github-release-token="$buildpack_github_release_token" \
  --var cnbs-dockerhub-password="$cnbs_dockerhub_password" \
  -c <(cat "$dir/pipelines/$pipeline/resources.yml" && echo "" && cat "$dir/pipelines/$pipeline/jobs.yml")
