#!/bin/bash
#set -o errexit

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")
KIND_REPO_ROOT_DIR=$(realpath "$SCRIPT_DIR/../")

# WIP
# https://spark.apache.org/docs/latest/running-on-kubernetes
#spark-submit \
#  --class org.apache.spark.examples.SparkPi \
#  --conf spark.kubernetes.container.image=bitnami/spark:latest \
#  --master k8s://https://127.0.0.1:44255 \
#  --conf spark.kubernetes.driverEnv.SPARK_MASTER_URL=spark://spark-master-0.spark-headless.spark.svc.cluster.local:7077 \
#  --deploy-mode cluster \
#  --conf spark.kubernetes.namespace=spark \
#   https://github.com/simpe00/test-exmaple-jar/raw/main/spark-examples_2.12-3.5.1.jar 1

# WIP
#spark-submit \
#  --conf spark.kubernetes.container.image=bitnami/spark:latest \
#  --master k8s://https://127.0.0.1:44255 \
#  --conf spark.kubernetes.driverEnv.SPARK_MASTER_URL=spark://spark-master-0.spark-headless.spark.svc.cluster.local:7077 \
#  --deploy-mode cluster \
#  --conf spark.kubernetes.namespace=spark \
#  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
#  --verbose \
#  https://raw.githubusercontent.com/simpe00/test-exmaple-jar/main/pi.py 1


# Test submit
# https://janetvn.medium.com/how-to-add-multiple-python-custom-modules-to-spark-job-6a8b943cdbbc
#kubectl exec -ti --namespace spark spark-worker-0 -- spark-submit --master spark://spark-master-svc:7077 \
#	--class org.apache.spark.examples.SparkPi \
#	https://raw.githubusercontent.com/simpe00/test-exmaple-jar/main/pi.py 1

# Example 2
kubectl exec -ti --namespace spark spark-master-0 -- spark-submit --master spark://spark-master-svc:7077 \
	--class org.apache.spark.examples.SparkPi \
	https://github.com/simpe00/test-exmaple-jar/raw/main/spark-examples_2.12-3.5.1.jar 1
