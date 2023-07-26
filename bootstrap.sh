#!/usr/bin/env bash
set -euo pipefail

. .env

export OCI_TENANCY_ID_B64="$(echo -n "$OCI_TENANCY_ID" | base64 | tr -d '\n')"
export OCI_CREDENTIALS_FINGERPRINT_B64="$(echo -n "$OCI_CREDENTIALS_FINGERPRINT" | base64 | tr -d '\n')"
export OCI_USER_ID_B64="$(echo -n "$OCI_USER_ID" | base64 | tr -d '\n')"
export OCI_REGION_B64="$(echo -n "$OCI_REGION" | base64 | tr -d '\n')"
export OCI_CREDENTIALS_KEY_B64=$(base64 < "${OCI_KEY_FILE}" | tr -d '\n')
export OCI_SSH_KEY=$(cat "${HOME}/.ssh/your/key/pair")
export KUBECONFIG=/tmp/kind.yaml # for exporting KIND kubeconfig
export EXP_MACHINE_POOL=true
export EXP_OKE=true
export CLUSTERCTL_LOG_LEVEL=10 # debug

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