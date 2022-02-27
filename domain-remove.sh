#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG

cd "$(dirname "$0")"

# Load env variables
source .env

docker run --rm -i \
-v "${GLOBAL_ROOT}/docker-data/letsencrypt:/etc/letsencrypt" \
-v "${GLOBAL_ROOT}/docker-data/certbot:/var/www/certbot" \
certbot/certbot 'delete'
