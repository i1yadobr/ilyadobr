#!/bin/bash

# Set up BYOND
source /home/server/byond/bin/byondsetup

if [[ "$VOLUMES_FILESYSTEM_WORKAROUND" == "true" ]]; then
    # Copy mounted configs and data and set up syncing the changes back into the mounted folders

    # NOTE(rufus): this is needed because BYOND cannot read files from the `9p` and `grpcfuse` filesystems.
    # Docker uses these filesystems to mount folders from Windows hosts into the Linux environments.
    # A proper solution for this would be to stop relying on files for persistence and move everything to DB.
    # Some could argue that a proper solution is to stop using Docker. A valid point, you do you.
    cp -r /ss13config /home/server/oldonyx/config
    cp -r /ss13data /home/server/oldonyx/data

    # Function to start syncing a specific directory, run this in the background
    sync_dir() {
        local source_dir=$1
        local target_dir=$2
        while inotifywait -r -e modify,create,delete,move "$source_dir"; do
            rsync -aqz "$source_dir" "$target_dir"
        done
    }
    # Backsync configs and data from the server into the mounted folders so they persist on the host machine
    sync_dir /home/server/oldonyx/config/ /ss13config/ > /dev/null 2>&1 &
    sync_dir /home/server/oldonyx/data/ /ss13data/ > /dev/null 2>&1 &
fi

# Move into the server folder and start
# Note that these two environment variables are set up in the Dockerfile
cd /home/server/oldonyx

if [[ "$COMPILE_BUILD" == "true" ]]; then
    DreamMaker $DME_FILE || { echo "Compilation failed, exiting..."; exit 1; }
fi

DreamDaemon $DMB_FILE $SERVER_PORT -trusted
