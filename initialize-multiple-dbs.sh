#!/bin/bash
set -e
set -u

function create_db() {
  local db=$1
  mysql -v -u root --password=$MYSQL_ROOT_PASSWORD <<-EOSQL
      -- create database
      CREATE DATABASE IF NOT EXISTS $db;

      -- If db name is not equal to env user, create user from db name
      DELIMITER $$
      IF '$db'!='$MYSQL_USER' THEN
        -- create user
        CREATE USER '$db' IDENTIFIED BY '$db';

        -- grant user server access
        GRANT USAGE ON *.* TO '$db'@'localhost' IDENTIFIED BY '$db';
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
