#!/usr/bin/env bash
set -e

# Функция для вывода сообщений
log() {
    echo -e "[\e[32m*\e[0m] $1"
}

log "Installing base packages"
apt update
apt install -y sudo curl ufw fail2ban

log "Full upgrade"
apt full-upgrade -y

log "Configuring UFW"
# Сброс правил (force чтобы не спрашивал подтверждения)
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
# Включение фаервола
ufw --force enable

log "Configuring Fail2Ban"
cat > /etc/fail2ban/jail.local <<EOF
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
# Проверяем статус, но не роняем скрипт, если fail2ban еще инициализируется
fail2ban-client status sshd || echo "Fail2ban status check skipped"

log "Installing Auto_IPtables"
# Запуск внешнего скрипта
curl -fsSL https://raw.githubusercontent.com/Loorrr293/Auto_IPtables/main/install.sh | bash

log "DONE"
