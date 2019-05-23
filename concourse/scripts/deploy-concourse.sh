#!/usr/bin/env bash

dir="$(cd "$(dirname $0)" && pwd)/.."

"$dir"/scripts/fetch-bosh-state.sh

pushd "$dir"
 eval "$(bbl print-env)"
popd

bosh deployments
bosh upload-stemcell --sha1 ef07828df4d2b16335381eae10ecacfd5ea5f029 \
  https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-xenial-go_agent?v=250.17

pushd "$dir/concourse-bosh-deployment/cluster"
    bosh deploy \
        -d concourse concourse.yml \
        -o operations/github-auth.yml \
        -o operations/privileged-https.yml \
        -o operations/tls.yml \
        -o operations/tls-vars.yml \
        -o operations/web-network-extension.yml \
        -o operations/scale.yml \
        -o operations/worker-ephemeral-disk.yml \
        -l ../../vars/concourse-vars-file.yml \
        -l ../versions.yml
popd
