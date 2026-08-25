

# Linux Server Setup & Hardening

## 📌 Project Overview

This project demonstrates how to configure and secure a fresh Ubuntu Linux server for production-ready application deployment.

The objective is to implement essential Linux administration and security practices including user management, SSH key-based authentication, firewall configuration, automatic security updates, Fail2Ban, system configuration, service management, and log monitoring.

By completing this project, the server is hardened against common attack vectors and prepared for future application deployments.

---

## 🎯 Project Objectives

* Create a non-root administrative user
* Configure SSH key-based authentication
* Disable SSH password authentication
* Configure UFW firewall
* Apply system updates
* Enable automatic security updates
* Install and configure Fail2Ban
* Configure server hostname and timezone
* Manage services using `systemctl`
* Inspect system logs using `journalctl`
* Verify all security configurations
* Document the complete server-hardening process

---

## 🏗️ Architecture

```text
                    Internet
                       |
                       |
                  Port 22 SSH
                       |
                       ▼
              ┌─────────────────┐
              │   UFW Firewall  │
              │                 │
              │ Allow: SSH 22   │
              │ Deny: Others    │
              └────────┬────────┘
                       |
                       ▼
              ┌─────────────────┐
              │   Ubuntu Server │
              │                 │
              │  Non-root User  │
              │  SSH Key Auth   │
              │  Fail2Ban       │
              │  Auto Updates   │
              └────────┬────────┘
                       |
             ┌─────────┴─────────┐
             ▼                   ▼
       System Services       System Logs
          systemctl          journalctl
                              /var/log/
```

---

# 🛠️ Technologies Used

| Technology          | Purpose                           |
| ------------------- | --------------------------------- |
| Ubuntu Linux        | Server operating system           |
| OpenSSH             | Secure remote administration      |
| SSH Keys            | Passwordless authentication       |
| UFW                 | Firewall management               |
| Fail2Ban            | Brute-force protection            |
| unattended-upgrades | Automatic security updates        |
| systemctl           | Service management                |
| journalctl          | System log inspection             |
| Git/GitHub          | Version control and documentation |

---

# 🚀 Server Setup

## 1. Connect to the Server

Connect to the newly provisioned Ubuntu server using the cloud provider's initial SSH user.

```bash
ssh ubuntu@SERVER_PUBLIC_IP
```

Verify the operating system:

```bash
cat /etc/os-release
```

Check the kernel:

```bash
uname -a
```

---

# 👤 2. User Setup

Create a dedicated administrative user.

```bash
sudo adduser devops
```

Add the user to the sudo group:

```bash
sudo usermod -aG sudo devops
```

Verify:

```bash
groups devops
```

Test the user:

```bash
su - devops
```

Verify sudo access:

```bash
sudo whoami
```

Expected:

```text
root
```

The `devops` user will be used for future server administration instead of the root account.

---

# 🔐 3. SSH Key Authentication

Generate an SSH key pair on the local machine.

### Linux / macOS / Git Bash

```bash
ssh-keygen -t ed25519
```

This creates:

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

Copy the public key to the server:

```bash
ssh-copy-id devops@SERVER_PUBLIC_IP
```

If `ssh-copy-id` is unavailable, manually add the public key:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```

Paste the contents of your local:

```text
id_ed25519.pub
```

Set permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

---

# 🔒 4. Disable SSH Password Authentication

Before disabling password authentication, verify that SSH key authentication works from another terminal.

Test:

```bash
ssh devops@SERVER_PUBLIC_IP
```

Once confirmed, edit SSH configuration:

```bash
sudo nano /etc/ssh/sshd_config
```

Set:

```text
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

Validate the configuration:

```bash
sudo sshd -t
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

Test the connection again from your local machine:

```bash
ssh devops@SERVER_PUBLIC_IP
```

> ⚠️ Always keep your existing SSH session open while testing a new SSH configuration. This prevents accidental lockout.

---

# 🧱 5. Configure UFW Firewall

Check firewall status:

```bash
sudo ufw status
```

Set default policies:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Allow SSH:

```bash
sudo ufw allow 22/tcp
```

Enable UFW:

```bash
sudo ufw enable
```

Check:

```bash
sudo ufw status verbose
```

Expected configuration:

```text
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
```

When deploying applications later, additional ports can be opened as required.

For example:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

---

# 🔄 6. System Updates

Update package information:

```bash
sudo apt update
```

Upgrade installed packages:

```bash
sudo apt upgrade -y
```

Remove unnecessary packages:

```bash
sudo apt autoremove -y
```

Check for pending updates:

```bash
apt list --upgradable
```

---

# 🤖 7. Automatic Security Updates

Install unattended-upgrades:

```bash
sudo apt install unattended-upgrades -y
```

Enable automatic updates:

```bash
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Check the service:

```bash
systemctl status unattended-upgrades
```

Check configuration:

```bash
cat /etc/apt/apt.conf.d/20auto-upgrades
```

A typical configuration contains:

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

---

# 🛡️ 8. Install Fail2Ban

Install Fail2Ban:

```bash
sudo apt install fail2ban -y
```

Enable the service:

```bash
sudo systemctl enable fail2ban
```

Start it:

```bash
sudo systemctl start fail2ban
```

Check status:

```bash
sudo systemctl status fail2ban
```

Check Fail2Ban jails:

```bash
sudo fail2ban-client status
```

Check SSH protection:

```bash
sudo fail2ban-client status sshd
```

Create a local configuration:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

Edit:

```bash
sudo nano /etc/fail2ban/jail.local
```

Example SSH configuration:

```ini
[sshd]

enabled = true
port = ssh
backend = systemd
maxretry = 5
findtime = 10m
bantime = 1h
```

Restart:

```bash
sudo systemctl restart fail2ban
```

---

# 🖥️ 9. Configure Hostname

Set a meaningful hostname:

```bash
sudo hostnamectl set-hostname ubuntu-prod-server
```

Verify:

```bash
hostnamectl
```

Check:

```bash
hostname
```

Expected:

```text
ubuntu-prod-server
```

---

# 🌍 10. Configure Timezone

Check current timezone:

```bash
timedatectl
```

List available timezones:

```bash
timedatectl list-timezones
```

For India:

```bash
sudo timedatectl set-timezone Asia/Kolkata
```

Verify:

```bash
timedatectl
```

Check current time:

```bash
date
```

---

# ⚙️ 11. Service Management with systemctl

Check service status:

```bash
sudo systemctl status ssh
```

Start a service:

```bash
sudo systemctl start ssh
```

Stop a service:

```bash
sudo systemctl stop ssh
```

Restart a service:

```bash
sudo systemctl restart ssh
```

Enable a service at boot:

```bash
sudo systemctl enable ssh
```

Disable a service:

```bash
sudo systemctl disable ssh
```

Check whether a service is enabled:

```bash
sudo systemctl is-enabled ssh
```

Check failed services:

```bash
systemctl --failed
```

---

# 📋 12. Log Inspection

View system logs:

```bash
sudo journalctl
```

View recent logs:

```bash
sudo journalctl -n 50
```

Follow logs in real time:

```bash
sudo journalctl -f
```

View SSH logs:

```bash
sudo journalctl -u ssh
```

View logs from the current boot:

```bash
sudo journalctl -b
```

Check `/var/log`:

```bash
sudo ls -lah /var/log/
```

Common log files include:

```text
/var/log/auth.log
/var/log/syslog
/var/log/kern.log
/var/log/dpkg.log
```

Inspect authentication logs:

```bash
sudo tail -f /var/log/auth.log
```

Search for failed SSH authentication:

```bash
sudo grep "Failed password" /var/log/auth.log
```

---

# 🔍 13. Server Security Verification

Check current user:

```bash
whoami
```

Check sudo access:

```bash
sudo whoami
```

Check SSH configuration:

```bash
sudo sshd -T | grep -E 'passwordauthentication|pubkeyauthentication|permitrootlogin'
```

Expected:

```text
passwordauthentication no
pubkeyauthentication yes
permitrootlogin no
```

Check firewall:

```bash
sudo ufw status verbose
```

Check Fail2Ban:

```bash
sudo fail2ban-client status
```

Check automatic updates:

```bash
systemctl status unattended-upgrades
```

Check hostname:

```bash
hostnamectl
```

Check timezone:

```bash
timedatectl
```

Check failed services:

```bash
systemctl --failed
```

---

# ✅ Security Checklist

| Security Requirement                  | Status |
| ------------------------------------- | ------ |
| Non-root administrative user created  | ☐      |
| Sudo privileges configured            | ☐      |
| SSH key authentication configured     | ☐      |
| SSH password authentication disabled  | ☐      |
| Root SSH login disabled               | ☐      |
| UFW installed                         | ☐      |
| Only SSH allowed by default           | ☐      |
| System packages updated               | ☐      |
| Automatic security updates enabled    | ☐      |
| Fail2Ban installed                    | ☐      |
| SSH Fail2Ban jail enabled             | ☐      |
| Hostname configured                   | ☐      |
| Timezone configured                   | ☐      |
| systemctl commands verified           | ☐      |
| journalctl commands verified          | ☐      |
| `/var/log/` inspected                 | ☐      |
| Final security verification completed | ☐      |

---

# 🧪 Verification Commands

Run the following commands before considering the project complete:

```bash
whoami
```

```bash
sudo whoami
```

```bash
sudo ufw status verbose
```

```bash
sudo fail2ban-client status
```

```bash
systemctl --failed
```

```bash
systemctl status unattended-upgrades
```

```bash
sudo sshd -T | grep -E 'passwordauthentication|pubkeyauthentication|permitrootlogin'
```

```bash
timedatectl
```

```bash
hostnamectl
```

```bash
sudo journalctl -n 50
```

---

# 📊 Final Server State

After completing the project, the server should have:

```text
Ubuntu Server
│
├── Non-root sudo user
│
├── SSH
│   ├── SSH key authentication
│   ├── Password authentication disabled
│   └── Root login disabled
│
├── UFW
│   ├── SSH allowed
│   └── Other inbound traffic denied
│
├── Fail2Ban
│   └── SSH brute-force protection
│
├── Automatic Security Updates
│
├── Correct Hostname
│
├── Correct Timezone
│
├── systemctl
│   └── Service management
│
└── Logging
    ├── journalctl
    └── /var/log/
```

---

# 🚀 Future Improvements

The project can be extended with additional DevOps practices:

* Nginx web server installation
* HTTPS with Let's Encrypt
* Docker installation
* Docker Compose
* Node.js application deployment
* Jenkins CI/CD
* GitHub Actions CI/CD
* Terraform infrastructure provisioning
* Ansible server configuration
* Prometheus monitoring
* Grafana dashboards
* Centralized logging
* Automated security scanning
* AWS EC2 deployment
* Automated server backup

---

# 📚 Learning Outcomes

After completing this project, you should be able to:

* Administer a Linux server without using the root account
* Configure secure SSH authentication
* Harden SSH against unauthorized access
* Configure and manage UFW
* Protect SSH using Fail2Ban
* Configure automatic security updates
* Manage Linux services using systemctl
* Analyze Linux system logs
* Configure hostname and timezone
* Perform basic Linux server security audits
* Prepare a Linux server for application deployment

---

# 👨‍💻 Project Status

**Status:** Completed / In Progress

**Level:** Intermediate

**Category:** Linux / DevOps / Server Security

**Platform:** Ubuntu Linux

---

## Author

**Sravan Reddy**

DevOps Engineer | Linux | AWS | Terraform | Docker | CI/CD | Monitoring
