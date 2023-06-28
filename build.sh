#!/bin/bash
export TACKLE2_VERSION=release-0.2

podman build . --build-arg TACKLE2_VERSION=${TACKLE2_VERSION} -t quay.io/gpte-devops-automation/tackle2-setup:latest
podman tag quay.io/gpte-devops-automation/tackle2-setup:latest quay.io/gpte-devops-automation/tackle2-setup:${TACKLE2_VERSION}
podman push quay.io/gpte-devops-automation/tackle2-setup:latest
podman push quay.io/gpte-devops-automation/tackle2-setup:${TACKLE2_VERSION}
