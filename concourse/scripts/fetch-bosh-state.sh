#!/usr/bin/env bash

dir="$(cd "$(dirname $0)" && pwd)/.."

lpass show --note 'Shared-Cloud Native Buildpacks/cncf-bbl-state' > "$dir/bbl-state.json"

mkdir -p "$dir/vars"

lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-57845 > "$dir"/vars/bbl.tfvars
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-48962 > "$dir"/vars/bosh-state.json
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-85040 > "$dir"/vars/cloud-config-vars.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-25035 > "$dir"/vars/concourse-vars-file.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-17643 > "$dir"/vars/director-vars-file.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-33876 > "$dir"/vars/director-vars-store.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-42893 > "$dir"/vars/jumpbox-state.json
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-47949 > "$dir"/vars/jumpbox-vars-file.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-79905 > "$dir"/vars/jumpbox-vars-store.yml
lpass show 'Shared-Cloud Native Buildpacks/bbl/vars' -q --attach att-2702221144863353409-82344 > "$dir"/vars/terraform.tfstate
