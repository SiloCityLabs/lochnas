#!/bin/bash

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "$(dirname "$0")"

# Load env variables
source .env

# Load ip's
source scripts/getip.sh

# Install docker
if ! [ -x "$(command -v docker)" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# Install docker-compose
if ! [ -x "$(command -v docker-compose)" ]; then
    apt install -y docker-compose
fi

# Docker Path builder
source scripts/enable-templates.sh

# Stop if running
docker-compose $DOCKER_FILES stop

# Check ports
source scripts/port-check.sh

# Check for updates
docker-compose pull

# Run
docker-compose $DOCKER_FILES up -d --build --remove-orphans --force-recreate

# Remove old images
docker image prune -f
docker volume prune -f

# After start
source scripts/after-start.sh