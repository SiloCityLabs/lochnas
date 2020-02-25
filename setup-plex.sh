#!/bin/bash

#root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#load env variables
source ./env.sh

if [ -z "$1" ]
  then
    echo "Please supply the plex claim token: 'setup-plex.sh tokenhere'"
    exit 1
fi

docker run --rm -i \
--name plextmp \
-v /tmp/transcode:/transcode:rw \
-v "${PLEX_DATA}:/data:rw" \
-v "${PERSISTENT_ROOT}/plex:/config:rw" \
--net host \
-e PLEX_UID="${PUID}" \
-e PLEX_CLAIM="$1" \
-e 'HOME=/config' \
-e 'CHANGE_CONFIG_DIR_OWNERSHIP=true' \
-e PLEX_GID="${PGID}" \
plexinc/pms-docker:latest