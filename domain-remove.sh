#!/bin/bash

cd "$(dirname "$0")"

# Load env variables
source .env

docker run --rm -i \
-v "${PERSISTENT_ROOT}/docker-data/letsencrypt:/etc/letsencrypt" \
-v "${PERSISTENT_ROOT}/docker-data/certbot:/var/www/certbot" \
certbot/certbot:arm64v8-latest 'delete'
