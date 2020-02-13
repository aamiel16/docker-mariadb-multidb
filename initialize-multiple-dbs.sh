#!/bin/bash
set -e
set -u

function create_db() {
  local db=$1
  local is_env_user=$([ $MYSQL_USER = $db ] && echo "2" || echo "0")
  local pass=$([ $MYSQL_USER = $db ] && echo "$MYSQL_PASS" || echo "$db")
  mysql -v -u root --password=$MYSQL_ROOT_PASSWORD <<-EOSQL
      -- create database
      CREATE DATABASE IF NOT EXISTS $db;

      -- create user and grant permissions
      DELIMITER $$
        IF $is_env_user > 0 THEN
          GRANT ALL PRIVILEGES ON $db.* TO '$db'@'%';
        ELSE
          CREATE USER '$db' IDENTIFIED BY '$pass';
          GRANT USAGE ON *.* TO '$db'@localhost IDENTIFIED BY '$pass';
          GRANT ALL PRIVILEGES ON $db.* TO '$db'@localhost;
        END IF;
      $$
      DELIMITER ;

      -- apply permissions
      FLUSH PRIVILEGES;
EOSQL
}

if [ -n "$MYSQL_MULTIPLE_DATABASES" ]; then
  echo "[IN PROGRESS] Creating multiple databases"
  for db in $(echo $MYSQL_MULTIPLE_DATABASES | tr ',' ' '); do
    create_db $db
  done
  echo "[DONE] Creating multiple databases"
fi
