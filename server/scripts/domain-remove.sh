#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG
echo "DONT RUN"
exit 1

docker run --rm -i \
-v "/docker-nas/docker-data/letsencrypt:/etc/letsencrypt" \
-v "/docker-nas/docker-data/certbot:/var/www/certbot" \
certbot/certbot 'delete'
