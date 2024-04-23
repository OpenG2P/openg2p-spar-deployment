#!/usr/bin/env bash

export SANDBOX_HOSTNAME=${SANDBOX_HOSTNAME:-dev.openg2p.net}
export SPAR_HOSTNAME=${SPAR_HOSTNAME:-spar.$SANDBOX_HOSTNAME}

COPY_UTIL=./copy_cm_func.sh
NS=spar-heml-test

echo "Create $NS namespace"
kubectl create ns $NS

$COPY_UTIL secret postgres-postgresql postgres $NS

helm -n $NS upgrade --install spar ../charts/spar-mapper-api -f values.yaml --set global.hostname=$SPAR_HOSTNAME --wait $@
