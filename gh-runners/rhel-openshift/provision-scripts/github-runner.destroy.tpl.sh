#!/bin/env bash

set -e

# CHECKS

if [ "$EUID" -eq 0 ]; then 
    echo "Must be ran as a non-root user"
    exit 1
fi

# INPUTS
GH_OWNER="%GH_OWNER%"
GH_REPO="%GH_REPO%"

ACTIONS_RUNNER_INSTALL_DIR="${HOME}/runner-${GH_OWNER}-${GH_REPO}"
ACTIONS_RUNNER_WORK_DIR="${ACTIONS_RUNNER_INSTALL_DIR}-work"

pushd $ACTIONS_RUNNER_INSTALL_DIR > /dev/null
    echo "> Stopping service..."
    sudo ./svc.sh stop

    echo "> Unregistering runner..."
    ACTIONS_RUNNER_INPUT_TOKEN=$(cat .github-runner-token)

    echo "> TOKEN: $ACTIONS_RUNNER_INPUT_TOKEN"
    ./config.sh remove --unattended --token "$ACTIONS_RUNNER_INPUT_TOKEN"

    echo "> Cleaning up..."
    rm -rf $ACTIONS_RUNNER_INSTALL_DIR
    rm -rf $ACTIONS_RUNNER_WORK_DIR
popd > /dev/null