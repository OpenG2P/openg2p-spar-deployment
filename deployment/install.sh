#!/usr/bin/env bash

export SANDBOX_HOSTNAME=${SANDBOX_HOSTNAME:-qa.openg2p.net}
export SPAR_MAPPER_HOSTNAME=${SPAR_MAPPER_HOSTNAME:-spar.$SANDBOX_HOSTNAME}
export SPAR_SELF_SERVICE_HOSTNAME=${SPAR_SELF_SERVICE_HOSTNAME:-spar.$SANDBOX_HOSTNAME}

COPY_UTIL=./copy_cm_func.sh
NS=spar-helm-test

echo "Create $NS namespace"
kubectl create ns $NS

$COPY_UTIL secret postgres-postgresql postgres $NS

# Install spar-mapper-api
echo "Installing spar-mapper-api..."
if helm -n $NS upgrade --install spar-mapper-api ../charts/spar-mapper-api -f mapper-values.yaml --set global.hostname=$SPAR_MAPPER_HOSTNAME --wait $@; then
    echo "spar-mapper-api installed successfully."
else
    echo "Failed to install spar-mapper-api."
    exit 1
fi

# Install spar-self-service-api
echo "Installing spar-self-service-api..."
if helm -n $NS upgrade --install spar-self-service-api ../charts/spar-self-service-api -f self-service-values.yaml --set global.hostname=$SPAR_SELF_SERVICE_HOSTNAME --wait $@; then
    echo "spar-self-service-api installed successfully."
else
    echo "Failed to install spar-self-service-api."
    exit 1
fi