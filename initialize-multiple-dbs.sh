#!/bin/bash
set -e
set -u

function create_db() {
  local db=$1
  local is_user=$([ $MYSQL_USER = $db ] && echo 1 || echo 0)
  local pass=$([ $MYSQL_USER = $db ] && echo "$MYSQL_PASS" || echo "$db")
  mysql -v -u root --password=$MYSQL_ROOT_PASSWORD <<-EOSQL
      -- create database
      CREATE DATABASE IF NOT EXISTS $db;

      -- create user and grant usage permission
      IF $is_user = 0 THEN
        CREATE USER '$db' IDENTIFIED BY '$pass' $$
        GRANT USAGE ON *.* TO '$db'@localhost IDENTIFIED BY '$pass' $$
      END IF;

      -- grant user access to database
      GRANT ALL PRIVILEGES ON $db.* TO '$db'@localhost;

      -- apply permissions
      FLUSH PRIVILEGES;
EOSQL
}

if [ -n "$MYSQL_MULTIPLE_DATABASES" ]; then
  echo "Creating multiple databases"
  for db in $(echo $MYSQL_MULTIPLE_DATABASES | tr ',' ' '); do
    create_db $db
  done
  echo "[DONE] Creating multiple databases"
fi
