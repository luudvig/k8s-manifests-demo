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
helm install istio-ingress gateway --create-namespace --namespace istio-ingress --repo $REPO --wait
```

**Apply configurations**

```sh
kubectl apply -f .
```
