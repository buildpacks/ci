#!/usr/bin/env bash

dir="$(cd "$(dirname $0)" && pwd)/.."

lpass show --note 'Shared-Cloud Native Buildpacks/cncf-bbl-state' > "$dir/bbl-state.json"

mkdir -p "$dir/vars"

lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-9583 > "$dir"/vars/bbl.tfvars
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-11137 > "$dir"/vars/bosh-state.json
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-84595 > "$dir"/vars/cloud-config-vars.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-41338 > "$dir"/vars/concourse-vars-file.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-17759 > "$dir"/vars/director-vars-file.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-69299 > "$dir"/vars/director-vars-store.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-57711 > "$dir"/vars/jumpbox-state.json.old
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-26545 > "$dir"/vars/jumpbox-vars-file.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-20696 > "$dir"/vars/jumpbox-vars-store.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-93249 > "$dir"/vars/terraform.tfstate
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-45337 > "$dir"/vars/terraform.tfstate.backup

eval "$(bbl print-env)"
bosh deployments
bosh upload-stemcell --sha1 ef07828df4d2b16335381eae10ecacfd5ea5f029 \
  https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-xenial-go_agent?v=250.17

git submodule update --init --recursive

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
