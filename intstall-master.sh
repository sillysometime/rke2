#!/bin/bash

set -e

# Variables
RKE2_VERSION="v1.28.8+rke2r1"
INSTALL_RKE2_CHANNEL="stable"

# Colors for output
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

log_info "Starting RKE2 Master installation..."

# Update system
log_info "Updating system packages..."
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y curl wget
elif command -v yum &> /dev/null; then
    yum update -y
    yum install -y curl wget
fi

# Disable firewall (adjust based on your security requirements)
log_info "Configuring firewall..."
if systemctl is-active --quiet ufw; then
    ufw disable
elif systemctl is-active --quiet firewalld; then
    systemctl disable firewalld --now
fi

# Create RKE2 config directory
mkdir -p /etc/rancher/rke2

# Copy configuration file
if [[ -f "../configs/rke2-config.yaml" ]]; then
    cp ../configs/rke2-config.yaml /etc/rancher/rke2/config.yaml
    log_info "Configuration file copied successfully"
else
    log_warn "Configuration file not found, using default settings"
fi

# Download and install RKE2
log_info "Downloading RKE2 installer..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=$INSTALL_RKE2_CHANNEL sh -

# Enable and start RKE2 server
log_info "Starting RKE2 server..."
systemctl enable rke2-server.service
systemctl start rke2-server.service

# Wait for RKE2 to be ready
log_info "Waiting for RKE2 to be ready..."
sleep 30

# Set up kubectl
export PATH=$PATH:/var/lib/rancher/rke2/bin
mkdir -p ~/.kube
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
chmod 600 ~/.kube/config

# Install kubectl if not present
if ! command -v kubectl &> /dev/null; then
    log_info "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
fi

# Get node token for worker nodes
NODE_TOKEN=$(cat /var/lib/rancher/rke2/server/node-token)
log_info "Node token: $NODE_TOKEN"
log_info "Save this token to join worker nodes"

# Display cluster info
log_info "Cluster information:"
kubectl get nodes
kubectl get pods -A

log_info "RKE2 Master installation completed successfully!"
log_info "To join worker nodes, use the following command on each worker:"
log_info "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=\"agent\" sh -"
log_info "Then create /etc/rancher/rke2/config.yaml with:"
log_info "server: https://$(hostname -I | awk '{print $1}'):9345"
log_info "token: $NODE_TOKEN"