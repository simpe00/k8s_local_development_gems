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

## Debugging

* [Debugging with fdb plugin](https://github.com/FoundationDB/fdb-kubernetes-operator/blob/main/docs/manual/debugging.md)