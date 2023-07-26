#!/usr/bin/env bash
set -euo pipefail
set -x

. .env

# create bootstrap cluster
kind create cluster --config kind.yaml || true
kind get kubeconfig --name capi > "$KUBECONFIG"

# install CAPI to bootstrap cluster
clusterctl init --infrastructure oci --wait-providers --addon helm --config ./clusterctl.yaml
kubectl wait deployments -n caaph-system caaph-controller-manager --for=condition=Available=true

# create management cluster
clusterctl generate cluster "${CLUSTER_NAME}" --from template.yaml --config ./clusterctl.yaml > cluster.yaml
kubectl apply -f cluster.yaml --wait
kubectl wait cluster "${CLUSTER_NAME}" --for=condition=Ready=true
clusterctl get kubeconfig "${CLUSTER_NAME}" > ./banshee.kubeconfig
kubectl cluster-info --kubeconfig ./"${CLUSTER_NAME}".kubeconfig

# install CAPI to management cluster
clusterctl init --infrastructure oci --wait-providers --kubeconfig ./"${CLUSTER_NAME}".kubeconfig
kubectl wait deployments -n caaph-system caaph-controller-manager --for=condition=Available=true --kubeconfig ./"${CLUSTER_NAME}".kubeconfig

# move management cluster resource to management cluster
clusterctl move --to-kubeconfig ./"${CLUSTER_NAME}".kubeconfig

# clean up
kind delete cluster --name capi