#!/bin/bash

# Make sure directory exists
mkdir -p /lochnas/docker-data/nginx/templates/

#Generate htpasswd
NGINX_PASSWORD="$(echo $GLOBAL_NGINX_PASSWORD | openssl passwd -1 -stdin)"
echo "$GLOBAL_NGINX_USERNAME:$NGINX_PASSWORD" > /lochnas/docker-data/nginx/.htpasswd
