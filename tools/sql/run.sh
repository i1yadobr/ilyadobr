#!/bin/sh

docker start onyxdb || docker run -d -p 3306:3306 --name onyxdb onyxdb --default_authentication_plugin=mysql_native_password
echo
echo "Container started!"
