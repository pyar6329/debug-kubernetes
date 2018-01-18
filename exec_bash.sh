#!/bin/bash

set -e

readonly SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))
readonly DEPLOYMENT_NAME="debug-kubernetes"
readonly DEPLOYMENT_FILE_NAME="deployment.yaml"

count=0
while :; do
  if [ "${count}" == "60" ]; then
    [ "$(uname)" == "Darwin" ] && osascript -e 'display notification "progress 60s" with title "debug-deployment"'
    exit 1
  fi

  ubuntu_status=$(kubectl get pod | grep "${DEPLOYMENT_NAME}" | awk '{print $3}')
  [ -z "${ubuntu_status}" ] && kubectl create -f "${SCRIPT_DIR}/${DEPLOYMENT_FILE_NAME}"
  [ "${ubuntu_status}" = "Running" ] && break

  count=$(expr $count + 1)
  sleep 1
done

pod_name=$(kubectl get pod | grep "${DEPLOYMENT_NAME}" | awk '{print $1}')

kubectl exec -it "${pod_name}" bash
kubectl delete -f "${SCRIPT_DIR}/${DEPLOYMENT_FILE_NAME}"
