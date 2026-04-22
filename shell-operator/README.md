**Build container image**

```sh
minikube image build . -t localhost/shell-operator:latest
```

**Apply configurations: base**

```sh
kubectl apply -f '00-*.yaml'
```

**Apply configurations: shell-operator**

```sh
kubectl apply -f '10-*.yaml'
```

**Apply configurations: rotating config**

```sh
kubectl apply -f '20-*.yaml'
```
