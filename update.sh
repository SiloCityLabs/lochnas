#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

export UPDATE_RUN="true"

cd "$(dirname "$0")"

git pull

# config updates
source scripts/config-updates.sh

apt-get update && apt -y dist-upgrade && apt autoremove

./start.sh