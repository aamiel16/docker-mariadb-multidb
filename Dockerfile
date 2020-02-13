FROM mariadb:10.4.12
COPY initialize-multiple-dbs.sh /docker-entrypoint-initdb.d/
