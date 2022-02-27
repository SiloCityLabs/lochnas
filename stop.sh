#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "$(dirname "$0")"

# Load env variables
source .env

wanip="$(dig +short myip.opendns.com @resolver1.opendns.com)"

# Docker Path builder
source scripts/enable-templates.sh

# Stop if already running
docker-compose $DOCKER_FILES stop

echo "Done"
