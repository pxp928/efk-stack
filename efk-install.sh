#!/bin/bash
set -euo pipefail

# Define variables.
C_YELLOW='\033[33m'
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)

# Wait until pods are ready.
# $1: namespace, $2: app label
wait_for_pods () {
  echo -e "${C_YELLOW}Waiting: $2 pods in $1...${C_RESET_ALL}"
  kubectl wait --timeout=5m --for=condition=ready pods -l app="$2" -n "$1"
}

helm repo add fluent https://fluent.github.io/helm-charts
helm repo add elastic https://helm.elastic.co

# Install Elastic
echo -e "${C_GREEN}Installing Elastic...${C_RESET_ALL}"
helm install elasticsearch --create-namespace -n logging elastic/elasticsearch -f "$GIT_ROOT"/elastic/values.yaml

# Wait for Elastic
wait_for_pods logging elasticsearch-master

# Install fluent-bit
echo -e "${C_GREEN}Installing fluent-bit...${C_RESET_ALL}"
helm install fluent-bit --create-namespace -n logging fluent/fluent-bit

# Install Kibana
echo -e "${C_GREEN}Installing kibana...${C_RESET_ALL}"
helm install kibana --create-namespace -n logging elastic/kibana

# Wait for Kibana
wait_for_pods logging kibana

# To visualize Kibana port-forward 5601 and navigate to localhost:5601
# kubectl port-forward -n logging deployment/kibana-kibana 5601
