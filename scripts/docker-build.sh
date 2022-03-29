#!/bin/bash

# defaults that can be overridden with environment variables.
: ${DEMO_IMG:=verticapy-jupyterlab}
: ${PYTHON_VERSION:=3.8-slim-buster}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_DIR=$(dirname $SCRIPT_DIR)

# The OSx version of bash calls the M1 chip "arm64", but if someone updates
# /bin/bash, then it will could use "aarch64" in $MACHTYPE
if [[ $MACHTYPE =~ ^aarch64 ]] || [[ $MACHTYPE =~ ^arm64 ]] ; then
  DOCKER_BUILDARGS+=( --platform linux/arm64/v8 )
fi

# Specify the python base image version to use
DOCKER_BUILDARGS+=( --build-arg PYTHON_VERSION=$PYTHON_VERSION )
# The name of the image
DOCKER_BUILDARGS+=( -t $DEMO_IMG )

docker build "${DOCKER_BUILDARGS[@]}" $REPO_DIR/docker-verticapy/
