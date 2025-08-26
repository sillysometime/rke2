#!/bin/bash

set -e

# Check parameters
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <MASTER_IP> [NODE_TOKEN]"
    echo "Example: $0 10.0.1.10"
    exit 1
fi

MASTER_IP=$1
NODE_TOKEN=$2

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

log_info "Starting RKE2 Worker installation..."

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

# Get node token if not provided
if [[ -z "$NODE_TOKEN" ]]; then
    log_info "Please enter the node token from master node:"
    read -r NODE_TOKEN
fi

# Create worker configuration
log_info "Creating worker configuration..."
cat > /etc/rancher/rke2/config.yaml << EOF
server: https://${MASTER_IP}:9345
token: ${NODE_TOKEN}
EOF

# Download and install RKE2 agent
log_info "Downloading RKE2 agent..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

# Enable and start RKE2 agent
log_info "Starting RKE2 agent..."
systemctl enable rke2-agent.service
systemctl start rke2-agent.service

log_info "RKE2 Worker installation completed successfully!"
log_info "Check the master node to verify this worker joined the cluster:"
log_info "kubectl get nodes"