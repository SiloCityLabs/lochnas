#!/bin/bash

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "$(dirname "$0")"

# config updates
source docker-templates/config-updates.sh

apt-get update && apt -y dist-upgrade && apt autoremove

git pull

./start.sh