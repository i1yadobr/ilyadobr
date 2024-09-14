FROM mariadb:latest

COPY schema/* /docker-entrypoint-initdb.d/

# Add the 24 hours wait_timeout so DB doesn't drop connection to the server idling overnight
RUN echo "[mysqld]\nwait_timeout=86400" >> /etc/mysql/conf.d/timeout_custom.cnf

# Ensure proper file permissions
RUN chmod 644 /etc/mysql/conf.d/timeout_custom.cnf

# Make sure to set a proper password if you're running a production server
ENV MARIADB_DATABASE=onyxdb MARIADB_ROOT_PASSWORD=pass
