#!/bin/sh

docker start onyxdb > /dev/null 2>&1 || {
	docker run -d -v onyxdb-files:/var/lib/mysql --network host --name onyxdb onyxdb --default_authentication_plugin=mysql_native_password
}
echo
echo "Container started!"
