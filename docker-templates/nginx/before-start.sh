#!/bin/bash

# Make sure directory exists
mkdir -p /docker-nas/docker-data/nginx/templates/

#Generate htpasswd
NGINX_PASSWORD="$(echo $GLOBAL_NGINX_PASSWORD | openssl passwd -1 -stdin)"
echo "$GLOBAL_NGINX_USERNAME:$NGINX_PASSWORD" > /docker-nas/docker-data/nginx/.htpasswd
