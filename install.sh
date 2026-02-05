#!/usr/bin/env bash
set -euo pipefail

# Установка sudo (если отсутствует) и обновление системы
apt install sudo -y
sudo apt update && sudo apt full-upgrade -y

# Установка необходимых пакетов
sudo apt install curl ufw fail2ban -y

# Настройка UFW (Firewall)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
sleep 3
y

# Включение UFW (с подтверждением 'y' для неинтерактивного режима)
echo "y" | sudo ufw enable

# Создание конфигурации fail2ban через tee
sudo tee /etc/fail2ban/jail.local > /dev/null <<'EOF'
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

# Перезапуск fail2ban и вывод статуса
sudo systemctl restart fail2ban
sleep 10
sudo fail2ban-client status sshd

# Запуск внешнего скрипта Auto_IPtables
curl -fsSL "https://raw.githubusercontent.com/Loorrr293/Auto_IPtables/main/install.sh" | sudo bash

echo "Установка и настройка завершены."
