#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
schedule:
- crontab: "* * * * *"
  allowFailure: true
EOF
else
  rotatingConfigs=$(kubectl get rotatingconfigs --all-namespaces --no-headers --output custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name)
  while read item
  do
    namespace="${item%% *}"
    name="${item##* }"
    values=$(kubectl get rotatingconfigs "${name}" --namespace "${namespace}" --output jsonpath --template={.spec.values})

    if kubectl get configmaps "${name}" --namespace "${namespace}" &> /dev/null
    then
      index=$(kubectl get configmaps "${name}" --namespace "${namespace}" --output jsonpath --template={.data.index})
      next=$((index+1))
      [ "${next}" -ge $(jq length <<< "${values}") ] && next=0
      value=$(jq .["${next}"] <<< "${values}")
      cat << EOF | kubectl apply --filename -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
  namespace: ${namespace}
data:
  index: "${next}"
  value: ${value}
EOF
    else
      value=$(jq .[0] <<< "${values}")
      cat << EOF | kubectl create --filename - --save-config
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
  namespace: ${namespace}
data:
  index: "0"
  value: ${value}
EOF
    fi
  done <<< "${rotatingConfigs}"
fi
