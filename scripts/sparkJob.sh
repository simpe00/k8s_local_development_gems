#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")
KIND_REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")

CLUSTER_NAME=$(grep 'name:' ${REPO_ROOT_DIR}/kind/kind-no-ssl.yaml | awk '{print $2}')
SERVER_URL=$(kind get kubeconfig --name="${CLUSTER_NAME}" | grep 'server:' | awk '{print $2}' )

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
 --conf spark.kubernetes.executor.podNamePrefix=spark-executor2 \
 --conf spark.kubernetes.driver.podTemplateContainerName=spark \
 --conf spark.kubernetes.executor.podTemplateContainerName=spark \
 --conf spark.kubernetes.driverEnv.SPARK_USER=spark \
 --conf spark.eventLog.enabled=true \
 --conf spark.kubernetes.driver.secretKeyRef.AWS_ACCESS_KEY_ID=minio:rootUser \
 --conf spark.kubernetes.driver.secretKeyRef.AWS_SECRET_ACCESS_KEY=minio:rootPassword \
 --conf spark.kubernetes.executor.secretKeyRef.AWS_ACCESS_KEY_ID=minio:rootUser \
 --conf spark.kubernetes.executor.secretKeyRef.AWS_SECRET_ACCESS_KEY=minio:rootPassword \
 --conf spark.eventLog.dir='s3a://spark/logs' \
 --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false \
 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 \
 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
 --conf spark.hadoop.fs.s3a.path.style.access=true \
 --conf spark.hadoop.com.amazonaws.services.s3.enableV4=true \
 --num-executors 1 \
 --verbose \
 https://raw.githubusercontent.com/simpe00/test-exmaple-jar/main/pi.py 100