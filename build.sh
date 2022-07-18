#!/bin/bash
VERSION=1.0

podman build . -t quay.io/gpte-devops-automation/tackle2-setup:latest
podman tag quay.io/gpte-devops-automation/tackle2-setup:latest quay.io/gpte-devops-automation/tackle2-setup:${VERSION}
podman push quay.io/gpte-devops-automation/tackle2-setup:latest
podman push quay.io/gpte-devops-automation/tackle2-setup:${VERSION}
