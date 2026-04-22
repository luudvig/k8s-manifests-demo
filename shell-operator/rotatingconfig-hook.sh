#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- apiVersion: stable.example.com/v1
  kind: RotatingConfig
  executeHookOnEvent: ["Added", "Deleted"]
  executeHookOnSynchronization: false
  allowFailure: true
schedule:
- crontab: "* * * * *"
  allowFailure: true
EOF
else
  jq --compact-output '.[]' "$BINDING_CONTEXT_PATH" | while read -r CONTEXT; do
    TYPE=$(jq --raw-output .type <<< "$CONTEXT")

    if [[ "$TYPE" == "Event" ]]; then
      NAMESPACE=$(jq --raw-output .object.metadata.namespace <<< "$CONTEXT")
      NAME=$(jq --raw-output .object.metadata.name <<< "$CONTEXT")
      WATCHEVENT=$(jq --raw-output .watchEvent <<< "$CONTEXT")

      if [[ "$WATCHEVENT" == "Added" ]]; then
        VALUE=$(jq --raw-output .object.spec.values[0] <<< "$CONTEXT")
        kubectl create configmap "$NAME" --from-literal=index="0" --from-literal=value="$VALUE" --namespace="$NAMESPACE"
      elif [[ "$WATCHEVENT" == "Deleted" ]]; then
        kubectl delete configmap "$NAME" --namespace="$NAMESPACE"
      fi
    elif [[ "$TYPE" == "Schedule" ]]; then
      ROTATINGCONFIGS=$(kubectl get rotatingconfig --all-namespaces --no-headers --output=custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name)

      while read ITEM; do
        NAMESPACE="${ITEM%% *}"
        NAME="${ITEM##* }"
        VALUES=$(kubectl get rotatingconfig "$NAME" --namespace="$NAMESPACE" --output=jsonpath --template={.spec.values})

        if ! kubectl get configmap "$NAME" --namespace="$NAMESPACE" &> /dev/null; then
          continue
        fi

        INDEX=$(kubectl get configmap "$NAME" --namespace="$NAMESPACE" --output=jsonpath --template={.data.index})
        INDEX=$(( (INDEX + 1) % ($(jq length <<< "$VALUES")) ))
        VALUE=$(jq .["$INDEX"] <<< "$VALUES")

        kubectl patch configmap "$NAME" --namespace="$NAMESPACE" --patch='{"data": {"index": "'$INDEX'", "value": '"$VALUE"'}}'
      done <<< "$ROTATINGCONFIGS"
    fi
  done
fi
