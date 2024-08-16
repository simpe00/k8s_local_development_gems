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


# Extract the cluster name from the kind-no-ssl.yaml file
CLUSTER_NAME=$(grep 'name:' ${KIND_REPO_ROOT_DIR}/kind/kind-no-ssl.yaml | awk '{print $2}')

# Check if the cluster exists
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Cluster $CLUSTER_NAME exists."
    read -p "Do you want to restart the cluster? (yes/no): " user_input

    # Check the user's input
    if [[ "$user_input" == "yes" ]]; then
        echo "Restarting the cluster."
        kind delete cluster --name ${CLUSTER_NAME}
        kind create cluster --config ${KIND_REPO_ROOT_DIR}/kind/kind-no-ssl.yaml
    elif [[ "$user_input" == "no" ]]; then
        echo "Use the existing cluster."
        kubectl config use-context kind-${CLUSTER_NAME}
    else
        echo "Invalid input. Please enter 'yes' or 'no'."
        exit 1
    fi
else
    echo "Cluster $CLUSTER_NAME does not exist."
    kind create cluster --config ${KIND_REPO_ROOT_DIR}/kind/kind-no-ssl.yaml
fi

kind create cluster --config ${KIND_REPO_ROOT_DIR}/kind/kind-no-ssl.yaml




