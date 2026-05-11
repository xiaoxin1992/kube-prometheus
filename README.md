# kube-prometheus
根据kube-prometheus，自定义了prometheus的组建

### 重新生成执行
```shell
./build.sh
```

### 部署使用
```shell
# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
# Note that due to some CRD size we are using kubectl server-side apply feature which is generally available since kubernetes 1.22.
# If you are using previous kubernetes versions this feature may not be available and you would need to use kubectl create instead.
kubectl apply --server-side -f manifests/setup
kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
kubectl apply -f manifests/
```

### 移除
```shell
kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
```


### Agent部署使用
```shell
# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
# Note that due to some CRD size we are using kubectl server-side apply feature which is generally available since kubernetes 1.22.
# If you are using previous kubernetes versions this feature may not be available and you would need to use kubectl create instead.
kubectl apply --server-side -f manifests-agent/setup
kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
kubectl apply -f manifests-agent/
```

### 移除
```shell
kubectl delete --ignore-not-found=true -f manifests-agent/ -f manifests-agent/setup
```