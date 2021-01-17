#!/bin/env bash

set -e

# CHECKS

if [ "$EUID" -eq 0 ]; then 
    echo "Must be ran as a non-root user"
    exit 1
fi

# INPUTS
GH_TOKEN="%GH_TOKEN%"
GH_OWNER="%GH_OWNER%"
GH_REPO="%GH_REPO%"
GH_RUNNER_VERSION="%GH_RUNNER_VERSION%"

echo "> Install depenedencies..."
sudo yum install -y jq

echo "> Downloading actions runner ($GH_RUNNER_VERSION)..."
curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz"

echo "> Installing runner..."
ACTIONS_RUNNER_INSTALL_DIR="${HOME}/runner-${GH_OWNER}-${GH_REPO}"
ACTIONS_RUNNER_WORK_DIR="${ACTIONS_RUNNER_INSTALL_DIR}-work"

mkdir -p $ACTIONS_RUNNER_INSTALL_DIR
mkdir -p $ACTIONS_RUNNER_WORK_DIR

tar -zxf actions.tar.gz --directory $ACTIONS_RUNNER_INSTALL_DIR
rm -f actions.tar.gz

sudo ${ACTIONS_RUNNER_INSTALL_DIR}/bin/installdependencies.sh

pushd $ACTIONS_RUNNER_INSTALL_DIR > /dev/null
    echo "> Configuring runner..."
    ACTIONS_RUNNER_INPUT_TOKEN=$(curl -sS --request POST --url "https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token" --header "authorization: Bearer ${GH_TOKEN}"  --header 'content-type: application/json' | jq -r .token)

    echo "> Token: $ACTIONS_RUNNER_INPUT_TOKEN"
    echo "$ACTIONS_RUNNER_INPUT_TOKEN" > .github-runner-token

    ./config.sh --unattended --replace \
        --name $HOSTNAME \
        --labels "rhel,openshift"\
        --work $ACTIONS_RUNNER_WORK_DIR \
        --url "https://github.com/${GH_OWNER}/${GH_REPO}" \
        --token $ACTIONS_RUNNER_INPUT_TOKEN

    echo "> Installing service..."
    sudo ./svc.sh install

    echo "> Starting service..."
    sudo ./svc.sh start
popd > /dev/null