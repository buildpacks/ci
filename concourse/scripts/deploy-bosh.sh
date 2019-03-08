#!/usr/bin/env bash

set +x
set -e

export BBL_GCP_SERVICE_ACCOUNT_KEY=$(lpass show --note 'Shared-Build Service/cncf-bbl-concourse-gcp-service-account')
bbl plan --lb-type concourse --iaas gcp --gcp-region us-east1
bbl up --debug