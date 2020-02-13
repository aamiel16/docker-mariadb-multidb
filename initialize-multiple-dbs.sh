#!/bin/bash
set -e
set -u

function create_db() {
  local db=$1
  local pass=$([ $MYSQL_USER = $db ] && echo "$MYSQL_PASS" || echo "$db")
  mysql -v -u root --password=$MYSQL_ROOT_PASSWORD <<-EOSQL
      -- create database
      CREATE DATABASE IF NOT EXISTS $db;

      -- If db name is not equal to env user, create user from db name
      DELIMITER $$
      IF '$db'!='$MYSQL_USER' THEN
        -- create user
        CREATE USER '$db' IDENTIFIED BY '$pass';

        -- grant user server access
        GRANT USAGE ON *.* TO '$db'@'localhost' IDENTIFIED BY '$pass';
      END IF $$
      DELIMITER ;

      -- grant user db privileges
      GRANT ALL PRIVILEGES ON $db.* TO '$db'@'%';

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
