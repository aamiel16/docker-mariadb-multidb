# docker-mariadb-multidb
Multiple databases with the official [https://hub.docker.com/_/mariadb](MariaDB) docker image

## Usage
1. Clone the repository
2. Mount the repository as a volume to `/docker-entrypoint-initdb.d`
3. Set the `POSTGRES_MULTIPLE_DATABASES` environment variable to be comma-seperated database names

    mariadb:
        image: mariadb:10.4.12
        volumes:
            - ../docker-mariadb-multidb:/docker-entrypoint-initdb.d
        environment:
            ...
            - MYSQL_ROOT_PASSWORD=
            - MYSQL_MULTIPLE_DATABASES=db1,db2
