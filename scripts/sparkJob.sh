#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")
KIND_REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")

CLUSTER_NAME=$(grep 'name:' ${REPO_ROOT_DIR}/kind/kind-no-ssl.yaml | awk '{print $2}')
SERVER_URL=$(kind get kubeconfig --name="${CLUSTER_NAME}" | grep 'server:' | awk '{print $2}' )

# WIP
# https://spark.apache.org/docs/latest/running-on-kubernetes
#spark-submit \
#  --class org.apache.spark.examples.SparkPi \
#  --conf spark.kubernetes.container.image=bitnami/spark:latest \
#  --master k8s://https://127.0.0.1:45521 \
#  --conf spark.kubernetes.driverEnv.SPARK_MASTER_URL=spark://spark-master-0.spark-headless.spark.svc.cluster.local:7077 \
#  --deploy-mode cluster \
#  --conf spark.kubernetes.namespace=spark \
#   https://github.com/simpe00/test-exmaple-jar/raw/main/spark-examples_2.12-3.5.1.jar 1

# http://minio-console-127-0-0-1.nip.io:32180/login
helm repo add minio https://charts.min.io/
helm repo update minio
helm upgrade \
	--install \
	minio \
	minio/minio \
	--namespace spark \
	--create-namespace \
	-f $REPO_ROOT_DIR/k8s/minio/base/values.yaml



docker build . -f $REPO_ROOT_DIR/docker/spark/Dockerfile -t bitnami/spark-with-user:latest
kind load docker-image bitnami/spark-with-user:latest -n pilatus-k8s



kubectl apply -f $REPO_ROOT_DIR/k8s/spark/base/sa.yaml
kubectl apply -f $REPO_ROOT_DIR/k8s/spark/base/role.yaml
kubectl apply -f $REPO_ROOT_DIR/k8s/spark/base/role-binding.yaml

kubectl delete pod -n spark spark --force --grace-period=0
# WIP
#  --conf spark.kubernetes.container.image=bitnami/spark-with-user:latest \
spark-submit \
 --class org.apache.spark.examples.SparkPi \
 --conf spark.kubernetes.container.image=bitnami/spark-with-user:latest \
 --conf spark.kubernetes.executor.container.image=bitnami/spark-with-user:latest \
 --master k8s://${SERVER_URL} \
 --deploy-mode cluster \
 --conf spark.kubernetes.namespace=spark \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
 --conf spark.kubernetes.driver.pod.name=spark \
 --conf spark.kubernetes.executor.podNamePrefix=spark-executor \
 --conf spark.kubernetes.driver.podTemplateContainerName=spark \
 --conf spark.kubernetes.executor.podTemplateContainerName=spark \
 --conf spark.kubernetes.driverEnv.SPARK_USER=spark \
 --conf spark.eventLog.enabled=false \
 --conf spark.eventLog.dir='s3a://my-bucket/spark-logs' \
 --num-executors 1 \
 --verbose \
 https://raw.githubusercontent.com/simpe00/test-exmaple-jar/main/pi.py 1


# Test submit
# https://janetvn.medium.com/how-to-add-multiple-python-custom-modules-to-spark-job-6a8b943cdbbc
#kubectl exec -ti --namespace spark spark-worker-0 -- spark-submit --master spark://spark-master-svc:7077 \
#	--class org.apache.spark.examples.SparkPi \
#	https://raw.githubusercontent.com/simpe00/test-exmaple-jar/main/pi.py 1

# Example 2
# kubectl exec -ti --namespace spark spark-master-0 -- spark-submit --master spark://spark-master-svc:7077 \
# 	--class org.apache.spark.examples.SparkPi \
# 	https://github.com/simpe00/test-exmaple-jar/raw/main/spark-examples_2.12-3.5.1.jar 1
