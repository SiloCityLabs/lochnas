#!/bin/bash

# Make sure directory exists
mkdir -p /docker-nas/docker-data/nginx/

#Generate htpasswd
NGINX_PASSWORD="$(echo $NGINX_PASSWORD | openssl passwd -1 -stdin)"
echo "$NGINX_USERNAME:$NGINX_PASSWORD" > /docker-nas/docker-data/nginx/.htpasswd
