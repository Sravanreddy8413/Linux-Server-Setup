#!/bin/bash

set -e

echo "Starting Linux server hardening..."

echo "[1] Updating packages"
sudo dnf update -y

echo "[2] Installing required packages"
sudo dnf install -y firewalld dnf-automatic

echo "[3] Enabling firewall"
sudo systemctl enable --now firewalld

echo "[4] Allowing SSH"
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

echo "[5] Configuring automatic updates"
sudo systemctl enable --now dnf-automatic.timer

echo "[6] SSH configuration validation"
sudo sshd -t

echo
echo "Hardening completed successfully."
