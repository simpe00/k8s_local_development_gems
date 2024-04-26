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


## Debugging

* [Debugging with fdb plugin](https://github.com/FoundationDB/fdb-kubernetes-operator/blob/main/docs/manual/debugging.md)