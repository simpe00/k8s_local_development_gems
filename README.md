# k8s

## Install all

Install kind
```shell
./scripts/installKind.sh
```

Install FDB into k8s
```shell
./scripts/installFDB.sh
```

Install FDB kubectl plugin
```shell
./scripts/installKubectlFDBPlugin.sh
```

Install completion for fdb plugin (adjust to your needs)
```shell
kubectl fdb completion zsh | sudo tee /usr/share/zsh/vendor-completions/_kubectl-fdb >/dev/null
```

Check FDB 
```shell
kubectl-fdb analyze test-cluster
```

## Start

Build the warp1ß image and upload it into kind
```shell
docker build -t warp10-standaloneplus:1.0.1 ./docker

kind load docker-image warp10-standaloneplus:1.0.1 -n pilatus-k8s
```

Start warp10
```shell
 k apply -f k8s/warp10-deploy.yaml 
```

## Spark

Install spark cli with asdf
[Install guid](https://github.com/jeffryang24/asdf-spark)

### Testing spark

Show WebUI
```shell
kubectl port-forward -n spark services/spark-master-svc 8080:80
```

```shell
export EXAMPLE_JAR=$(kubectl exec -ti --namespace spark spark-worker-0 -- find examples/jars/ -name 'spark-example*\.jar' | tr -d '\r')

kubectl exec -ti --namespace spark spark-worker-0 -- spark-submit --master spark://spark-master-svc:7077 \
    --class org.apache.spark.examples.SparkPi \
    $EXAMPLE_JAR 500 
```

Install Metrics Server for using HPA
```shell
kubectl apply -f k8s/metric-server.yaml
```

## Debugging

* [Debugging with fdb plugin](https://github.com/FoundationDB/fdb-kubernetes-operator/blob/main/docs/manual/debugging.md)