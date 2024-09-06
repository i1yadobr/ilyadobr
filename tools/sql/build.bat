@echo off
docker build -t onyxdb .
echo.
if errorlevel 1 (
	echo Failed to build the image!
	pause
	exit
)
echo Image built!
pause