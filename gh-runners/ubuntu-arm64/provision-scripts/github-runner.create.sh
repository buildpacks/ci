#!/bin/bash

set -e

# CHECKS

export RUNNER_ALLOW_RUNASROOT="1"

# INPUTS

echo "> Downloading actions runner (${GH_RUNNER_VERSION})..."
curl -o "actions-runner-linux-arm64-${GH_RUNNER_VERSION}.tar.gz" -L "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-arm64-${GH_RUNNER_VERSION}.tar.gz"
echo "> Validating hash..."
echo "${GH_RUNNER_SHA256}  actions-runner-linux-arm64-${GH_RUNNER_VERSION}.tar.gz" | shasum -a 256 -c

echo "> Installing runner..."
ACTIONS_RUNNER_INSTALL_DIR="${HOME}/runner-${GH_OWNER}-${GH_REPO}"
ACTIONS_RUNNER_WORK_DIR="${ACTIONS_RUNNER_INSTALL_DIR}-work"

mkdir -p $ACTIONS_RUNNER_INSTALL_DIR
mkdir -p $ACTIONS_RUNNER_WORK_DIR

tar -zxf actions-runner-linux-arm64-${GH_RUNNER_VERSION}.tar.gz --directory $ACTIONS_RUNNER_INSTALL_DIR
rm -f actions-runner-linux-arm64-${GH_RUNNER_VERSION}.tar.gz

sudo ${ACTIONS_RUNNER_INSTALL_DIR}/bin/installdependencies.sh

pushd $ACTIONS_RUNNER_INSTALL_DIR > /dev/null
    echo "> Configuring runner..."
    if [[ -z "${GH_RUNNER_REG_TOKEN}" ]]; then
      GH_RUNNER_REG_TOKEN=$(curl -sS --request POST --url "https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token" --header "authorization: Bearer ${GH_TOKEN}"  --header 'content-type: application/json' | jq -r .token)
    fi

    ./config.sh --unattended --replace \
        --name $HOSTNAME \
        --labels "linux-arm64"\
        --work $ACTIONS_RUNNER_WORK_DIR \
        --url "https://github.com/${GH_OWNER}/${GH_REPO}" \
        --token $GH_RUNNER_REG_TOKEN

    echo "> Installing service..."
    sudo ./svc.sh install

    echo "> Starting service..."
    sudo ./svc.sh start
popd > /dev/null
