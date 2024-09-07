# This is a Linux script to build and run a Docker container with the server
# Make sure that you have Docker installed and Docker Daemon/Engine is running
# This script will stop any existing containers named `zeroonyx` and will remove any images named `zeroonyx-server`

# This script must be started from the root folder of the build
# This script will automatically mount your config/ and data/ folders into the container.
# Please adjust the `docker run` command if you want to change this behavior.

echo "Removing old container and image"

docker rm -f zeroonyx > /dev/null 2>&1
docker image rm zeroonyx-server > /dev/null 2>&1

echo "Building docker image!"

docker build -t zeroonyx-server . || (echo "Failed to build the image" && exit)

echo
echo "Image built, starting..."

docker run -d -p 14076:14076 -e VOLUMES_FILESYSTEM_WORKAROUND=false -v $(pwd)/config:/home/server/zeroonyx/config -v $(pwd)/data:/home/server/zeroonyx/data --network host --name zeroonyx zeroonyx-server || (echo "Failed to start the container" && exit)

echo
echo "Container successfully started!"
