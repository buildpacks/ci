#!/usr/bin/env bash

source /opt/resource/common.sh
start_docker 3 3 "" "--storage-driver=aufs"

docker_run() {
    docker run -v /var/run/docker.sock:/var/run/docker.sock --network host -v $(pwd):/workspace -w=/workspace "$@"
}
