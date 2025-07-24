#!/bin/bash

# Скрипт установки PostgreSQL и настройки peer-доступа через Linux-пользователя

set -e

LINUX_USER="user"
DB_NAME="userdb"

echo "=== Установка PostgreSQL ==="
sudo apt update
sudo apt install -y postgresql postgresql-contrib

echo "=== Создание системного пользователя $LINUX_USER ==="
if id "$LINUX_USER" &>/dev/null; then
    echo "Пользователь $LINUX_USER уже существует"
else
    sudo adduser --disabled-password --gecos "" $LINUX_USER
    echo "Пользователь $LINUX_USER создан"
fi

echo "=== Настройка PostgreSQL для peer-аутентификации ==="
# Убедимся, что в pg_hba.conf включён peer-доступ для local
PG_HBA="/etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf"

sudo sed -i "s/^local\s\+all\s\+all\s\+.*$/local   all             all                                     peer/" "$PG_HBA"

echo "=== Перезапуск PostgreSQL ==="
sudo systemctl restart postgresql

echo "=== Создание PostgreSQL-пользователя и базы данных ==="
sudo -u postgres psql <<EOF
CREATE USER $LINUX_USER;
CREATE DATABASE $DB_NAME OWNER $LINUX_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $LINUX_USER;
EOF

echo "✅ Готово!"

echo
echo "🔐 Теперь вы можете подключаться так:"
echo "  sudo -i -u $LINUX_USER"
echo "  psql -d $DB_NAME"