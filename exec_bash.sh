#!/bin/bash

set -e

readonly SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))

count=0
while :; do
  if [ "${count}" == "60" ]; then
    [ "$(uname)" == "Darwin" ] && osascript -e 'display notification "progress 60s" with title "proris-script"'
    exit 1
  fi

  UBUNTU_STATUS=$(kubectl get pod | grep ubuntu | awk '{print $3}')
  [ -z "${UBUNTU_STATUS}" ] && kubectl create -f "${SCRIPT_DIR}/deployment.yml"
  [ "${UBUNTU_STATUS}" = "Running" ] && break

  count=$(expr $count + 1)
  sleep 1
done

kubectl exec -it ubuntu bash
kubectl delete -f "${SCRIPT_DIR}/deployment.yml"
