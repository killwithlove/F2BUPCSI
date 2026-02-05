#!/bin/bash

# Обновляем списки пакетов и устанавливаем sudo (если его нет, например, в чистом Debian)
apt update
apt install sudo -y

# Полное обновление системы
sudo apt update && sudo apt full-upgrade -y

# Установка необходимых утилит
sudo apt install curl ufw fail2ban -y

# Настройка Firewall (UFW)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp

# Включение UFW (флаг 'yes' подтверждает действие без запроса)
echo "y" | sudo ufw enable

# Создание конфигурации Fail2Ban (jail.local)
sudo bash -c 'cat <<EOF > /etc/fail2ban/jail.local
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
EOF'

# Перезапуск Fail2Ban и вывод статуса
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd

# Запуск внешнего скрипта Auto_IPtables
curl -fsSL "https://raw.githubusercontent.com/Loorrr293/Auto_IPtables/main/install.sh" | sudo bash
