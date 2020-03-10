#!/usr/bin/env bash

set +x
set -e

export BBL_GCP_SERVICE_ACCOUNT_KEY=$(lpass show --note 'Shared-Cloud Native Buildpacks/cncf-bbl-concourse-gcp-service-account')

echo "We're not too sure the latest bbl works. For guaranteed satisfaction, you might check out version 7.4.0"

bbl plan --lb-type concourse --iaas gcp --gcp-region us-east1
bbl up --debug
