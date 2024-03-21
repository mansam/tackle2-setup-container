#!/bin/bash
export TACKLE2_VERSION=release-0.3

podman build . --build-arg TACKLE2_VERSION=${TACKLE2_VERSION} -t quay.io/gpte-devops-automation/tackle2-setup:${TACKLE2_VERSION}-mta7
podman push quay.io/gpte-devops-automation/tackle2-setup:${TACKLE2_VERSION}-mta7
