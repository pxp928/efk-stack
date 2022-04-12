#!/bin/bash
set -euo pipefail

# Define variables.
C_YELLOW='\033[33m'
C_RESET_ALL='\033[0m'

# Wait until pods are ready.
# $1: namespace, $2: app label
wait_for_pods () {
  echo -e "${C_YELLOW}Waiting: $2 pods in $1...${C_RESET_ALL}"
  kubectl wait --timeout=5m --for=condition=ready pods -l app="$2" -n "$1"
}

helm repo add fluent https://fluent.github.io/helm-charts
helm repo add elastic https://helm.elastic.co

# Install Elastic
helm install elasticsearch elastic/elasticsearch -f ./elastic/values.yaml

# Wait for Elastic
wait_for_pods default elasticsearch-master

# Install fluent-bit
helm install fluent-bit fluent/fluent-bit

# Install Kibana
helm install kibana elastic/kibana

# Wait for Kibana
wait_for_pods default kibana
