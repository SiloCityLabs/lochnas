#!/bin/bash

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "$(dirname "$0")"

# Load env variables
source .env

# Docker Path builder
source docker-templates/enable-templates.sh

# Stop if already running
docker-compose $DOCKER_FILES stop
