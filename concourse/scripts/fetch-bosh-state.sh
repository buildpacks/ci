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