FROM mariadb:latest

COPY migrate/* /docker-entrypoint-initdb.d/

ENV MARIADB_DATABASE=feedback MARIADB_ROOT_PASSWORD=pass
