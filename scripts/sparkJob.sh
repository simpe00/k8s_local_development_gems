#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")
KIND_REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")

spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --conf spark.kubernetes.container.image=bitnami/spark:latest \
  --master k8s://https://127.0.0.1:44255 \
  --conf spark.kubernetes.driverEnv.SPARK_MASTER_URL=spark://spark-master-0.spark-headless.spark.svc.cluster.local:7077 \
  --deploy-mode cluster \
  --conf spark.files.overwrite=true \
  --conf spark.kubernetes.namespace=spark \
   https://github.com/simpe00/test-exmaple-jar/blob/main/spark-examples_2.12-3.5.1.jar 1
