#!/usr/bin/env bash

RED='\033[1;31m'
NC='\033[0m' # No Color

terraform --help &> /dev/null
if [[ $? != 0 ]]; then
  echo -e "${RED}Error${NC}: Terraform must be installed and on the PATH: brew install terraform"
  exit 1
fi

set -e

DIR=$(cd $(dirname "$0") && cd .. && pwd)

# TODO: these credentials are to be set up by maintainers
export TF_VAR_PACKET_AUTH_TOKEN="$(lpass show --note 'Shared-Cloud Native Buildpacks/packet-auth-token')"
export TF_VAR_PROJECT_ID="$(lpass show --note 'Shared-Cloud Native Buildpacks/packet-project-id')"

cd "$DIR/terraform"
if [ -z "$1" ] || [ "$1" == "apply" ]; then
  terraform init
  terraform plan
fi
terraform ${@:-apply}