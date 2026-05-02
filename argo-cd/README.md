**Install Argo CD**

```sh
REPO='https://argoproj.github.io/argo-helm'

helm install argo-cd argo-cd --create-namespace --namespace argocd --repo $REPO --set configs.params.server\\.insecure=true
```

**Argo CD: LoadBalancer**

```sh
kubectl patch service argo-cd-argocd-server --namespace=argocd --patch='{"spec": {"type": "LoadBalancer"}}'
```

**Argo CD: Login**

```sh
ARGOCD_IP=$(kubectl get service argo-cd-argocd-server --namespace=argocd --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
ARGOCD_PW=$(kubectl get secret argocd-initial-admin-secret --namespace=argocd --output=jsonpath="{.data.password}" | base64 -d)

argocd login $ARGOCD_IP --username admin --password $ARGOCD_PW
```

**Argo CD: Register cluster**

```sh
argocd cluster add $(kubectl config get-contexts --output=name)
```

**Argo CD: Example application**

```sh
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```
