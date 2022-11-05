#!/bin/bash

# Install plugin to nextcloud
if [[ $NEXTCLOUD_ENABLED -eq "true" ]]; then

    if [[ ! -d /lochnas/docker-data/nextcloud/html/apps/richdocuments ]]; then
        docker exec -u $GLOBAL_UID -it nextcloud php occ app:install richdocuments
    fi

    #Use username and password if set in the environment varibles for the url
    # if [[ ! -z "${GLOBAL_COLLABORA_USERNAME}" ]]; then
    #     docker exec -u $GLOBAL_UID -it nextcloud php occ config:app:set --value https://${GLOBAL_COLLABORA_USERNAME}:${GLOBAL_COLLABORA_PASSWORD}@office.$GLOBAL_DOMAIN richdocuments wopi_url
    # else
        docker exec -u $GLOBAL_UID -it nextcloud php occ config:app:set --value https://office.$GLOBAL_DOMAIN richdocuments wopi_url
    # fi

    docker exec -u $GLOBAL_UID -it nextcloud php occ richdocuments:activate-config
fi




