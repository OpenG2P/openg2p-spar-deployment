#!/usr/bin/env bash

export SANDBOX_HOSTNAME=${SANDBOX_HOSTNAME:-openg2p.sandbox.net}
export SPAR_HOSTNAME=${SPAR_HOSTNAME:-spar.$SANDBOX_HOSTNAME}
export NS=${NS:-spar}

helm repo add openg2p https://openg2p.github.io/openg2p-helm
helm repo update

helm -n $NS --create-namespace upgrade --install spar openg2p/spar --set global.sparHostname=$SPAR_HOSTNAME --wait $@
