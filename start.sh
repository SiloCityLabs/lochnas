#!/bin/bash

#root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#load env variables
source ./env.sh

#install docker and compose
if ! [ -x "$(command -v docker)" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
    apt-get install apt-transport-https ca-certificates curl software-properties-common
    apt install -y docker-ce
fi

if ! [ -x "$(command -v docker-compose)" ]; then
    apt install -y docker-compose
fi

#just in case its already running
docker-compose stop

# Make all folders
mkdir -p plex
mkdir -p certbot
mkdir -p mariadb
mkdir -p homeassistant
mkdir -p nextcloud
mkdir -p homeassistant
mkdir -p portainer
mkdir -p /tmp/transcode
mkdir -p transmission/scripts
mkdir -p transmission/config
mkdir -p transmission/data

#check for updates
docker-compose pull

#run
docker-compose up -d