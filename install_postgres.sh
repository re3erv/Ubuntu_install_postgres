#!/bin/bash

# Скрипт установки PostgreSQL и создания пользователя и базы

set -e

DB_USER="user"
DB_PASS="1234"
DB_NAME="userdb"

echo "=== Установка PostgreSQL ==="
sudo apt update
sudo apt install -y postgresql postgresql-contrib

echo "=== Запуск и включение PostgreSQL ==="
sudo systemctl enable postgresql
sudo systemctl start postgresql

echo "=== Создание пользователя и базы данных ==="
# Выполняем SQL от имени postgres
sudo -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF

echo "=== Создание файла .pgpass ==="
PGPASS_FILE="$HOME/.pgpass"
echo "localhost:5432:*:$DB_USER:$DB_PASS" > "$PGPASS_FILE"
chmod 600 "$PGPASS_FILE"
echo "Файл $PGPASS_FILE создан и защищён."

echo "✅ Готово. Вы можете подключаться так:"
echo "    psql -U $DB_USER -d $DB_NAME"
