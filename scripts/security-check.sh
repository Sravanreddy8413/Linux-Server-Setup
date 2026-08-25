#!/bin/bash

echo "======================================"
echo " Linux Server Security Check"
echo "======================================"

echo

echo "[1] Current User"
whoami

echo
echo "[2] Hostname"
hostname

echo
echo "[3] Timezone"
timedatectl | grep "Time zone"

echo
echo "[4] SSH Service"
systemctl is-active sshd

echo
echo "[5] Firewall"
firewall-cmd --state

echo
echo "[6] Fail2ban"
systemctl is-active fail2ban

echo
echo "[7] SSH Configuration"
sshd -T 2>/dev/null | grep -E \
"permitrootlogin|passwordauthentication|pubkeyauthentication"

echo
echo "[8] Listening Ports"
ss -tulpn

echo
echo "======================================"
echo " Security Check Completed"
echo "======================================"
