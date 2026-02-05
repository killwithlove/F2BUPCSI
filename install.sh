#!/usr/bin/env bash
# =============================================================================
#  harden.sh — скрипт начальной защиты сервера (Debian/Ubuntu)
# =============================================================================

set -euo pipefail

# Цвета для удобства
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}▶ Начинаем hardening сервера...${NC}\n"

# 1. Устанавливаем sudo, если его нет
if ! command -v sudo >/dev/null 2>&1; then
    echo -e "${YELLOW}sudo не найден. Устанавливаем...${NC}"
    apt update -qq
    apt install -y sudo
    echo -e "${GREEN}sudo установлен${NC}"
fi

# 2. Полное обновление системы
echo -e "\n${YELLOW}Обновляем систему...${NC}"
sudo apt update -qq && sudo apt full-upgrade -y && sudo apt autoremove -y
echo -e "${GREEN}Система обновлена${NC}"

# 3. Устанавливаем curl
sudo apt install -y curl

# 4. Настраиваем UFW
echo -e "\n${YELLOW}Настраиваем UFW...${NC}"
sudo apt install -y ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS

echo -e "y" | sudo ufw enable
sudo ufw status verbose

echo -e "${GREEN}UFW включён${NC}"

# 5. Устанавливаем и настраиваем Fail2Ban
echo -e "\n${YELLOW}Устанавливаем Fail2Ban...${NC}"
sudo apt install -y fail2ban

cat << 'EOF' | sudo tee /etc/fail2ban/jail.local > /dev/null
[DEFAULT]
backend     = systemd
bantime     = 60d
findtime    = 2m
maxretry    = 1
ignoreip    = 127.0.0.1/8 ::1 127.0.0.1

[sshd]
enabled  = true
port     = 22
mode     = aggressive
logpath  = %(sshd_log)s
EOF

sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

echo -e "\n${YELLOW}Статус sshd jail:${NC}"
sudo fail2ban-client status sshd

echo -e "${GREEN}Fail2Ban настроен (бан на 60 дней, maxretry=1)${NC}"

# =============================================================================
#  Опционально: скрипт Auto_IPtables
# =============================================================================
echo -e "\n${RED}ВНИМАНИЕ!${NC} Следующая команда запускает скрипт который блокирует нежелательные подсети :"
echo "curl -fsSL \"https://raw.githubusercontent.com/Loorrr293/Auto_IPtables/main/install.sh\" | sudo bash"

curl -fsSL "https://raw.githubusercontent.com/Loorrr293/Auto_IPtables/main/install.sh" | sudo bash

echo -e "\n${GREEN}Готово! Сервер значительно безопаснее.${NC}"