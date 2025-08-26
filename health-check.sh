#!/bin/bash

# RKE2 Health Check Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "Starting RKE2 cluster health check..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check cluster nodes
log_info "Checking cluster nodes..."
kubectl get nodes -o wide

# Check system pods
log_info "Checking system pods..."
kubectl get pods -n kube-system

# Check RKE2 services
log_info "Checking RKE2 services..."
if systemctl is-active --quiet rke2-server; then
    log_info "RKE2 server service is running"
elif systemctl is-active --quiet rke2-agent; then
    log_info "RKE2 agent service is running"
else
    log_error "RKE2 service is not running"
fi

# Check cluster info
log_info "Cluster information:"
kubectl cluster-info

# Check node conditions
log_info "Node conditions:"
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'

log_info "Health check completed!"