#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG
echo "DONT RUN"
exit 1

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
-v "/docker-nas/docker-data/letsencrypt:/etc/letsencrypt" \
-v "/docker-nas/docker-data/certbot:/var/www/certbot" \
-p 80:80 \
-p 443:443 \
certbot/certbot 'certonly' '--standalone' \
"-d $1" '--agree-tos' "-m $GLOBAL_EMAIL"

if [ $DOCKER_STOPPED = true ]; then
    docker container start nginx
fi
