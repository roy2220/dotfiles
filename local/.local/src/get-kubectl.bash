#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail # -o xtrace

K8S_VERSION=$(curl --silent --show-error --fail --request GET --location https://dl.k8s.io/release/stable.txt)
TEMP_FILE=$(mktemp)
curl --silent --show-error --fail --request GET --location "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl" --output "${TEMP_FILE}"
install "${TEMP_FILE}" kubectl
rm --force "${TEMP_FILE}"
