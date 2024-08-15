#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CURRENT_DIR=$(pwd)
REPO_ROOT_DIR="$SCRIPT_DIR/../"
source $SCRIPT_DIR/define-colors.sh
MINIO_K8S_NAMESPACE="spark"
COMPANY_NAME="pilatus"
##
## define global vars
##
STAGE_ID=""
###
### parse parameters
###

while :; do
    case $1 in
        -s|--stageId)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                STAGE_ID=$2
            fi
            shift
            ;;
        --)          # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done


if [ -z "${STAGE_ID}" ]; then
    echo 'ERROR: "-s|--stageId" requires a non-empty option argument.'
    exit 1
fi
if [[ "${STAGE_ID}" != @(local|ops|testing) ]]; then
    echo "invalid value --STAGE_ID $STAGE_ID, allowed values are 'local', 'ops' and 'testing'"
    exit 1
else
    echo -e "${GREEN} STAGE_ID=$STAGE_ID ${NO_COLOR}"
fi

echo "create spark namespace"
kubectl create namespace $MINIO_K8S_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

CLUSTER_NAME=$(grep 'name:' ${REPO_ROOT_DIR}/kind/kind-no-ssl.yaml | awk '{print $2}')
SERVER_URL=$(kind get kubeconfig --name="${CLUSTER_NAME}" | grep 'server:' | awk '{print $2}' )


echo -e "${GREEN} install minio for ${COMPANY_NAME} on stage ${STAGE_ID} ${NO_COLOR}"

helm repo add minio https://charts.min.io/
helm repo update minio

MINIO_HELM_VERSION="5.2.0"
MINIO_RELEASE_NAME="minio"

# http://minio-console-127-0-0-1.nip.io:32180/login
helm upgrade \
    --install \
    ${MINIO_RELEASE_NAME} \
    minio/minio \
    --version ${MINIO_HELM_VERSION} \
    -n ${MINIO_K8S_NAMESPACE} \
    -f ${REPO_ROOT_DIR}k8s/minio/base/values.yaml \
    -f ${REPO_ROOT_DIR}k8s/minio/${STAGE_ID}/values.yaml





