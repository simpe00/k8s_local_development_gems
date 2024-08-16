#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CURRENT_DIR=$(pwd)
REPO_ROOT_DIR="$SCRIPT_DIR/../"
source $SCRIPT_DIR/define-colors.sh
SPARK_HS_K8S_NAMESPACE="spark"
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
kubectl create namespace $SPARK_HS_K8S_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -


cd "${REPO_ROOT_DIR}" || exit

docker pull quay.io/tcarland/spark:v3.5.1-callisto-2407.30
kind load docker-image quay.io/tcarland/spark:v3.5.1-callisto-2407.30 -n pilatus-k8s

helm repo add spark-hs-chart https://tcarland.github.io/spark-hs-chart/

SPARK_HS_HELM_VERSION="1.0.6"

echo -e "${GREEN} install spark history server for ${COMPANY_NAME} on stage ${STAGE_ID} ${NO_COLOR}"
SPARK_HS_RELEASE_NAME="spark-hs"
helm upgrade --install \
  ${SPARK_HS_RELEASE_NAME} \
  spark-hs-chart/spark-hs \
  --version ${SPARK_HS_HELM_VERSION} \
  -n ${SPARK_HS_K8S_NAMESPACE} \
  -f ${REPO_ROOT_DIR}k8s/spark-hs/base/values.yaml \
  -f ${REPO_ROOT_DIR}k8s/spark-hs/${STAGE_ID}/values.yaml

#echo "waiting for pods to be ready"
#kubectl rollout status statefulset "${SPARK_HS_RELEASE_NAME}" -n $SPARK_HS_K8S_NAMESPACE --watch --timeout=3m

# switch back to the original directory
cd $CURRENT_DIR