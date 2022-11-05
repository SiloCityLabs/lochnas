#!/bin/bash

# Dont run if nextcloud has not been installed yet
FILE=/lochnas/docker-data/nextcloud/html/config/config.php
if test -f "$FILE"; then
    # apparently nextcloud is doing integrity checks so i cant delete for now
    # Broken plugin
    # if [[ -d /lochnas/docker-data/nextcloud/html/apps/files_trashbin ]]; then
    #     echo "Removing broken plugin 'Deleted Files' because it conflicts with External Storage"
    #     rm -rf /lochnas/docker-data/nextcloud/html/apps/files_trashbin
    #     # This plugin causes 403 errors in ios/Android app when deleting files on External storage
    #     # files_trashbin could not be removed as it is a shipped app, so lets just delete it so we dont have to keep running this
    #     # docker exec -u $GLOBAL_UID -it nextcloud php occ app:delete files_trashbin
    # fi

    docker exec -u $GLOBAL_UID -it nextcloud php occ app:disable files_trashbin

    # Preview plugin
    if [[ ! -d /lochnas/docker-data/nextcloud/html/custom_apps/previewgenerator ]]; then
        echo "Installing preview cron plugin"
        # rm -rf /lochnas/docker-data/nextcloud/html/apps/files_trashbin
        docker exec -u $GLOBAL_UID -it nextcloud php occ app:install previewgenerator

        echo "Run the following command once to pre-generate all thumbnails"
        echo "docker exec -u $GLOBAL_UID -it nextcloud php occ preview:generate-all -vvv"
    fi

    # docker exec -u $GLOBAL_UID -it nextcloud php occ maintenance:repair --include-expensive

    # TODO: Possibly uninstall the following plugins:
    # docker exec -u $GLOBAL_UID -it nextcloud php occ app:disable richdocuments
fi

# bug in nginx cache http/s redirect infinit loop
echo "Waiting..."
sleep 15s #time it takes for nextcloud to startup
echo "Restart Nginx"
docker restart nginx