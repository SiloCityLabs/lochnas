#!/bin/bash

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "$(dirname "$0")/../../"

# Load env variables
source .env

# Load ip's
source scripts/getip.sh

if [ -z "$1" ]
  then
    echo "Please supply the plex claim token: 'setup.sh tokenhere'"
    exit 1
fi

# Check if data folder exists
if [ ! -d $GLOBAL_ROOT/docker-data/plex ]; then
  echo "Creating docker-data/plex directory" && mkdir $GLOBAL_ROOT/docker-data/plex
else
  echo "Plex folder already exists, exiting."
  exit 1
fi

echo "Now starting plex, check your server at port http://$HOSTNAME:32400/web. Press CTRL + C once you confirm its up and running."

docker run --rm -i \
--name plextmp \
-v /tmp/transcode:/transcode:rw \
-v "${PLEX_DATA}:/data:rw" \
-v "/docker-nas/docker-data/plex:/config:rw" \
--net host \
-e PLEX_UID="${GLOBAL_UID}" \
-e PLEX_GID="${GLOBAL_GID}" \
-e PLEX_CLAIM="$1" \
-e 'HOME=/config' \
-e 'CHANGE_CONFIG_DIR_OWNERSHIP=true' \
-e PLEX_GID="${PGID}" \
plexinc/pms-docker:latest
