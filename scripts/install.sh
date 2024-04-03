#!/usr/bin/env bash

export SANDBOX_HOSTNAME=${SANDBOX_HOSTNAME:-openg2p.sandbox.net}
export SPAR_HOSTNAME=${SPAR_HOSTNAME:-spar.$SANDBOX_HOSTNAME}

COPY_UTIL=./copy_cm_func.sh
NS=spar

echo Create $NS namespace
kubectl create ns $NS

$COPY_UTIL secret postgres-postgresql postgres $NS

kubectl -n $NS delete cm mapper-registry-schemas --ignore-not-found=true
kubectl -n $NS create cm mapper-registry-schemas --from-file=schemas/FinancialAddressMapper.json


helm -n $NS upgrade --install spar ../helm/charts/spar-mapper-api --set global.hostname=$SPAR_HOSTNAME --wait $@
