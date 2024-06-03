#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CURRENT_DIR=$(pwd)
REPO_ROOT_DIR="$SCRIPT_DIR/../"
source $SCRIPT_DIR/define-colors.sh
SPARK_K8S_NAMESPACE="spark"
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
kubectl create namespace $SPARK_K8S_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -


cd "${REPO_ROOT_DIR}" || exit

SPARK_HELM_VERSION="9.1.0"

echo -e "${GREEN} install spark for ${COMPANY_NAME} on stage ${STAGE_ID} ${NO_COLOR}"
SPARK_RELEASE_NAME="spark"
helm upgrade --install \
  ${SPARK_RELEASE_NAME} \
  oci://registry-1.docker.io/bitnamicharts/spark \
  --version ${SPARK_HELM_VERSION} \
  -n ${SPARK_K8S_NAMESPACE} \
  -f ${REPO_ROOT_DIR}k8s/spark/base/values.yaml \
  -f ${REPO_ROOT_DIR}k8s/spark/${STAGE_ID}/values.yaml

#echo "waiting for pods to be ready"
#kubectl rollout status statefulset "${SPARK_RELEASE_NAME}" -n $SPARK_K8S_NAMESPACE --watch --timeout=3m

# switch back to the original directory
cd $CURRENT_DIR