#!/bin/bash

# Install plugin to nextcloud
if [[ $NEXTCLOUD_ENABLED -eq "true" ]]; then

    if [[ ! -d /docker-nas/docker-data/nextcloud/html/apps/richdocuments ]]; then
        docker exec -u $GLOBAL_UID -it nextcloud php occ app:install richdocuments
    fi

    #Use username and password if set in the environment varibles for the url
    if [[ ! -z "${username}" ]]; then
        docker exec -u $GLOBAL_UID -it nextcloud php occ config:app:set --value https://${username}:${password}@office.$GLOBAL_DOMAIN/ richdocuments wopi_url
    else
        docker exec -u $GLOBAL_UID -it nextcloud php occ config:app:set --value https://office.$GLOBAL_DOMAIN/ richdocuments wopi_url
    fi

    docker exec -u $GLOBAL_UID -it nextcloud php occ richdocuments:activate-config
fi




