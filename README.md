**Start cluster**

```sh
minikube start --cpus='4' --memory='7800m'
```

**Connect LoadBalancer**

```sh
minikube tunnel --cleanup
```

**Install Istio**

```sh
REPO='https://istio-release.storage.googleapis.com/charts'

helm install istio-base base --create-namespace --namespace istio-system --repo $REPO --set defaultRevision=default
helm install istiod istiod --namespace istio-system --repo $REPO --wait
```

**Install gateway**

```sh
helm install istio-ingress gateway --create-namespace --namespace istio-ingress --repo $REPO --wait
```

*or*

```sh
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml --server-side
```

**Apply configurations: base**

```sh
kubectl apply -f '[01]0-*.yaml'
```

**Apply configurations: gateway**

```sh
kubectl apply -f '20-*.yaml'
```

*or*

```sh
kubectl apply -f '30-*.yaml'
```

**Apply configurations: route**

```sh
kubectl apply -f '21-*.yaml'
```

*or*

```sh
kubectl apply -f '31-*.yaml'
```
