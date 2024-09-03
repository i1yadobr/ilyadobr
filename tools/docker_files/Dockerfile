# TODO(rufus): switch to a lightweight ubuntu or even alpine, tg has examples
FROM archlinux:base

# You can adjust these arguments as needed
ARG BYOND_MAJOR=515
ARG BYOND_MINOR=1643
ENV DME_FILE=baystation12.dme
ENV DMB_FILE=baystation12.dmb
ENV SERVER_PORT=14076
# The build be compiled from source files inside the container if true. Otherwise, will use whichever .dmb it copied from the host directory.
# Disabling saves you the compilation time on startup, so if you're building the .dmb yourself (with VSCode build tasks for example), feel free to disable. 
# Default is on to allow for all-in-one script behavior to just run the server, should be useful for new contributors.
ENV COMPILE_BUILD=true

# NOTE(rufus): This configures a workaround for BYOND compatibility with Docker's `9p` and `grpcfuse` filesystems, which are used when mounting Windows host file systems into Linux containers. BYOND can't to access files on these filesystems but operates normally with `ext4` and `tmpfs`. To address this, files will be copied, and a background rsync loop will sync changes like logs or player data back to the host OS for persistence.
# IMPORTANT: Set to true when using Docker Desktop on Windows to launch containers. Since this might affect performance, avoid using Windows+Linux Docker Containers. Instead, host directly from Windows or use Linux+Linux Docker containers which will mount the folders without problematic filesystems.
# TL;DR Using Windows? Set to true. Otherwise set to false.
ENV VOLUMES_FILESYSTEM_WORKAROUND=true


# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm wget unzip make inotify-tools rsync lib32-glibc lib32-gcc-libs

# Download and install BYOND
RUN wget https://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip -O byond.zip && \
    unzip byond.zip -d /home/server && \
    rm byond.zip && \
    cd /home/server/byond && \
    make here

COPY . /home/server/oldonyx/

# Two volumes that will be used for copying files into the server and backsyncing files from the server onto the host machine. Only relevant if VOLUMES_FILESYSTEM_WORKAROUND=true.
# Note that if VOLUMES_FILESYSTEM_WORKAROUND is set to false, you have to use docker-build-and-run.sh script for Linux environments which already includes mounting commands or mount /config and /data folders yourself. 
VOLUME ["/ss13config", "/ss13data"]

# Expose the port our server will use
EXPOSE $SERVER_PORT

# The rest of the setup will be done inside the container with this script
ENTRYPOINT ["/home/server/oldonyx/docker-entrypoint.sh"]
