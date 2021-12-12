#!/bin/bash

if [[ $PERSISTENT_ROOT == "" ]]; then
   echo "Do not run this file directly, use start.sh or stop.sh"
fi

# ==========================
# Nextcloud
# ==========================
if [[ $NEXTCLOUD_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nextcloud/nextcloud.docker-compose.yml"

   # Broken plugin
   if [[ -d $PERSISTENT_ROOT/docker-data/nextcloud/html/apps/files_trashbin ]]; then
      echo "Removing broken plugin 'Deleted Files' because it conflicts with External Storage"
      rm -rf $PERSISTENT_ROOT/docker-data/nextcloud/html/apps/files_trashbin
      # This plugin causes 403 errors in ios/Android app when deleting files on External storage
      # files_trashbin could not be removed as it is a shipped app, so lets just delete it so we dont have to keep running this
      # docker exec -u 33 -it nextcloud php occ app:remove files_trashbin
   fi

   # Preview plugin
   if [[ ! -d $PERSISTENT_ROOT/docker-data/nextcloud/html/custom_apps/previewgenerator ]]; then
      echo "Installing preview cron plugin"
      # rm -rf $PERSISTENT_ROOT/docker-data/nextcloud/html/apps/files_trashbin
      docker exec -u $PUID -it nextcloud php occ app:install previewgenerator

      echo "Run the following command once to pre-generate all thumbnails"
      echo "docker exec -u $PUID -it nextcloud php occ preview:generate-all -vvv"
   fi

   # bug in nginx cache http/s redirect infinit loop
   sleep 15s #time it takes for nextcloud to startup
   docker restart nginx
   
   # Force update nextcoud db then kick it out of maintenance mode.
   docker exec -u $PUID -it nextcloud php occ maintenance:repair --include-expensive
   docker exec -u $PUID -it nextcloud php occ maintenance:mode --off
fi
