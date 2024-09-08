#!/bin/sh

docker start onyxdb || {
	docker run -d -v zero-onyx-db-files:/var/lib/mysql --network host --name onyxdb onyxdb --default_authentication_plugin=mysql_native_password
}
echo
echo "Container started!"
