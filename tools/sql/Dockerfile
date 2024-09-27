FROM mariadb:latest

COPY schema/* /docker-entrypoint-initdb.d/

# Make sure to set a proper password if you're running a production server
ENV MARIADB_DATABASE=onyxdb MARIADB_ROOT_PASSWORD=pass
