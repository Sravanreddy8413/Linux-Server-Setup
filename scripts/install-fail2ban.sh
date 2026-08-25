#!/bin/bash

set -e

echo "Installing Fail2ban..."

sudo dnf install fail2ban -y

sudo mkdir -p /etc/fail2ban

sudo tee /etc/fail2ban/jail.local > /dev/null <<'EOF'
[sshd]
enabled = true
port = ssh
backend = systemd
maxretry = 5
findtime = 10m
bantime = 1h
EOF

sudo systemctl enable --now fail2ban

echo "Fail2ban installation completed."

sudo fail2ban-client status
