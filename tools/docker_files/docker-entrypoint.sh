#!/bin/bash

if [[ "$VOLUMES_FILESYSTEM_WORKAROUND" == "true" ]]; then
    # Copy mounted configs and data and set up syncing the changes back into the mounted folders

    # NOTE(rufus): this is needed because BYOND *cannot* read files from the `9p` and `grpcfuse` filesystems.
    # Docker uses these filesystems to mount folders from Windows hosts into the Linux environments.

    # This exists exclusively for the purpose of comaptibility with Docker Desktop for *Windows*.
    # [your files]->[container] - files only passed once, when the container is started, live changes won't be reflected
    # [container] ->[your files] - changes will be reflected in realtime, logs and player data will update in your files as the game goes
    cp -r /ss13config $(pwd)/config
    cp -r /ss13data $(pwd)/data

    # Function to start syncing a specific directory, run this in the background
    sync_dir() {
        local source_dir=$1
        local target_dir=$2
        while inotifywait -r -e modify,create,delete,move "$source_dir"; do
            rsync -aqz "$source_dir" "$target_dir"
        done
    }
    # Backsync configs and data from the server into the mounted folders so they persist on the host machine
    # Note the trailing slashes in paths, these are important, otherwise you'll get infinite recursive copies
    sync_dir $(pwd)/config/ /ss13config/ > /dev/null 2>&1 &
    sync_dir $(pwd)/data/ /ss13data/ > /dev/null 2>&1 &
fi

LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./" DreamDaemon $DMB_FILE $SERVER_PORT -trusted
