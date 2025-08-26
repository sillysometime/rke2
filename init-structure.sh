#!/bin/bash
# Script to initialize Rancher RKE2 project structure

set -e

echo "[*] Creating project structure..."

# Root files
touch README.md

# ansible inventories
mkdir -p ansible/inventories/production/group_vars
touch ansible/inventories/production/hosts.yml
touch ansible/inventories/production/group_vars/all.yml
touch ansible/inventories/production/group_vars/masters.yml
touch ansible/inventories/production/group_vars/workers.yml

# ansible playbooks
mkdir -p ansible/playbooks
touch ansible/playbooks/site.yml
touch ansible/playbooks/prerequisites.yml
touch ansible/playbooks/install-rke2.yml
touch ansible/playbooks/post-install.yml

# ansible roles
mkdir -p ansible/roles/common
mkdir -p ansible/roles/rke2-master
mkdir -p ansible/roles/rke2-worker

# scripts
mkdir -p scripts
touch scripts/install-master.sh
touch scripts/install-worker.sh
touch scripts/backup-etcd.sh
touch scripts/health-check.sh

# configs
mkdir -p configs
touch configs/rke2-config.yaml
touch configs/registries.yaml
touch configs/security-policy.yaml

# docs
mkdir -p docs
touch docs/INSTALL.md
touch docs/TROUBLESHOOTING.md
touch docs/MAINTENANCE.md

echo "[*] Project structure created successfully!"
