#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG

cd "$(dirname "$0")"
cd ..

# Load env variables
source .env

# Check if nginx is running
DOCKER_STOPPED=false
if [ "$(docker ps -q -f name=nginx)" ]; then
    if [ "$(docker ps -aq -f status=running -f name=nginx)" ]; then
        #need to stop temp
        docker container stop nginx
        DOCKER_STOPPED=true
    fi
fi

if [ -z "$1" ]
  then
    echo "Please supply the domain name: 'add-domain.sh domain.com'"
    exit 1
fi

docker run --rm -i \
-v "${GLOBAL_ROOT}/docker-data/letsencrypt:/etc/letsencrypt" \
-v "${GLOBAL_ROOT}/docker-data/certbot:/var/www/certbot" \
-p 80:80 \
-p 443:443 \
certbot/certbot 'certonly' '--standalone' \
"-d $1" '--agree-tos' "-m $GLOBAL_EMAIL"

if [ $DOCKER_STOPPED = true ]; then
    docker container start nginx
fi
