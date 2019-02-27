#!/usr/bin/env bash

lpass_note() {
  lpass show --notes "Shared-Build Service/$1"
}

dir="$(cd "$(dirname "$0")" && pwd)"

concourse_service_account_key=$(lpass_note 'cncf-concourse-service-account-json-key')
pack_github_release_token=$(lpass_note 'buildpack-pack-cli-github-release-token')

cat <(cat $dir/resources.yml && cat $dir/jobs.yml) | pbcopy

fly -t buildpacksio set-pipeline \
  -p buildpack \
  --var concourse-service-account-key-json="$concourse_service_account_key" \
  --var pack-github-release-token="$pack_github_release_token" \
  -c <(cat $dir/resources.yml && cat $dir/jobs.yml)
