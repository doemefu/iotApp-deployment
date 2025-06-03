#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME=${CLUSTER_NAME:-iotapp}

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is required. Install from https://kind.sigs.k8s.io/" >&2
  exit 1
fi

# Create cluster if it does not exist
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --name "${CLUSTER_NAME}"
fi

kubectl create namespace iot --dry-run=client -o yaml | kubectl apply -f -

# Apply manifests
kubectl apply -f k8s/secrets.yaml
for dir in 1-postgres 2-influx 3-mosquitto 4-user-management 5-auth 6-device-management 7-data-processing 8-frontend 00-traefik 98-deployment-prod; do
  kubectl apply -f "k8s/${dir}"
done
kubectl apply -f k8s/ingress.yaml
