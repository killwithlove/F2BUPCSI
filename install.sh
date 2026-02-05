#!/bin/bash

set -e

echo "[*] Установка необходимых пакетов"
apt install sudo -y
apt update && apt full-upgrade -y
apt install curl ufw fail2ban -y

echo "[*] Настройка UFW"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "[*] Настройка Fail2Ban"

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
backend = systemd
bantime = 60d
findtime = 2m
maxretry = 1
ignoreip = 127.0.0.1/8

[sshd]
enabled = true
port = 22
mode = aggressive
EOF

systemctl restart fail2ban

echo "[*] Статус Fail2Ban (sshd)"
fail2ban-client status sshd || true

echo "[*] Установка Auto_IPtables"
curl -fsSL "https://raw.githubusercontent.com/Loorrr293/Auto_IPtables/main/install.sh" | bash

echo "[✔] Готово"
