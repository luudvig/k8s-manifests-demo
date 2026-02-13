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

| istio | gateway |
| - | - |
| `helm install istio-ingress gateway --create-namespace --namespace istio-ingress --repo $REPO --wait` | `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml --server-side` |

**Apply configurations: kiali**

```sh
kubectl apply -f '00-*.yaml'
```

**Apply configurations: base**

```sh
kubectl apply -f '[12]0-*.yaml'
```

**Apply configurations: gateway**

| istio | gateway |
| - | - |
| `kubectl apply -f '30-*.yaml'` | `kubectl apply -f '31-*.yaml'` |

**Apply configurations: route**

| istio | gateway |
| - | - |
| `kubectl apply -f '40-*.yaml'` | `kubectl apply -f '41-*.yaml'` |
