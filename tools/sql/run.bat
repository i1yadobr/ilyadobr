@echo off
docker start onyxdb 2>nul
if errorlevel 1 (
	docker run -d -p 3306:3306 --name onyxdb onyxdb --default_authentication_plugin=mysql_native_password
	if errorlevel 1 (
		echo.
		echo Failed to start the container!
		pause
		exit
	)
)
echo.
echo Container started!
pause