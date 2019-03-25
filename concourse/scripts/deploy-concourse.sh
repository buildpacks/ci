#!/usr/bin/env bash

dir="$(cd "$(dirname $0)" && pwd)/.."

lpass show --note 'Shared-Build Service/cncf-bbl-state' > "$dir/bbl-state.json"

mkdir -p "$dir/vars"

lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-11659 > "$dir"/vars/bbl.tfvars
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-50881 > "$dir"/vars/bosh-state.json
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-30313 > "$dir"/vars/cloud-config-vars.yml
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-75277 > "$dir"/vars/director-vars-file.yml
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-77144 > "$dir"/vars/jumpbox-state.json.old
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-51580 > "$dir"/vars/director-vars-store.yml
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-89885 > "$dir"/vars/jumpbox-vars-file.yml
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-52091 > "$dir"/vars/jumpbox-vars-store.yml
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-8279 > "$dir"/vars/terraform.tfstate
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-29659 > "$dir"/vars/terraform.tfstate.backup
lpass show 'Shared-Build Service/bbl/vars' -q --attach att-2138333814489501575-19874 > "$dir"/vars/concourse-vars-file.yml

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
