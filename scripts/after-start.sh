#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO docker-templates

if [[ $GLOBAL_ROOT == "" ]]; then
   echo "Do not run this file directly, use start.sh or stop.sh"
fi

# ==========================
# Nextcloud
# ==========================
if [[ $NEXTCLOUD_ENABLED == "true" ]]; then
   # Broken plugin
   if [[ -d $GLOBAL_ROOT/docker-data/nextcloud/html/apps/files_trashbin ]]; then
      echo "Removing broken plugin 'Deleted Files' because it conflicts with External Storage"
      rm -rf $GLOBAL_ROOT/docker-data/nextcloud/html/apps/files_trashbin
      # This plugin causes 403 errors in ios/Android app when deleting files on External storage
      # files_trashbin could not be removed as it is a shipped app, so lets just delete it so we dont have to keep running this
      # docker exec -u 33 -it nextcloud php occ app:remove files_trashbin
   fi

   # Preview plugin
   if [[ ! -d $GLOBAL_ROOT/docker-data/nextcloud/html/custom_apps/previewgenerator ]]; then
      echo "Installing preview cron plugin"
      # rm -rf $GLOBAL_ROOT/docker-data/nextcloud/html/apps/files_trashbin
      docker exec -u $GLOBAL_UID -it nextcloud php occ app:install previewgenerator

      echo "Run the following command once to pre-generate all thumbnails"
      echo "docker exec -u $GLOBAL_UID -it nextcloud php occ preview:generate-all -vvv"
   fi

   # docker exec -u $GLOBAL_UID -it nextcloud php occ maintenance:repair --include-expensive

   # bug in nginx cache http/s redirect infinit loop
   echo "Waiting..."
   sleep 15s #time it takes for nextcloud to startup
   echo "Restart Nginx"
   docker restart nginx
fi
