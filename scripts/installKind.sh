#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")
KIND_REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")

#HELM_BUILD_DIR="$REPO_ROOT_DIR/helm-deploy"
#mkdir -p $HELM_BUILD_DIR
#source $SCRIPT_DIR/define-colors.sh
K8S_NAMESPACE=""
STAGE_ID=local




kind create cluster --config ${KIND_REPO_ROOT_DIR}/kind/kind-no-ssl.yaml




