#!/bin/bash

if [[ $PERSISTENT_ROOT == "" ]]; then
   echo "Do not run this file directly, use start.sh or stop.sh"
fi

# Check if data folder exists
[ ! -d $PERSISTENT_ROOT/docker-data ] && echo "Creating docker-data directory" && mkdir -p $PERSISTENT_ROOT/docker-data/certbot

# Build string of enabled containers
DOCKER_FILES="-f docker-compose.yml"

# Samba
if [[ $SAMBA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/samba/samba.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/samba ] && echo "Creating docker-data/samba directory" && mkdir $PERSISTENT_ROOT/docker-data/samba

   # Check if config file exists or copy it
   [ ! -f $PERSISTENT_ROOT/docker-data/samba/smb.conf ] && echo "Creating docker-data/samba/smb.conf file" && cp $PERSISTENT_ROOT/docker-templates/samba/smb.conf $PERSISTENT_ROOT/docker-data/samba/smb.conf

fi

# PHPMyAdmin
if [[ $PHPMYADMIN_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/phpmyadmin/phpmyadmin.docker-compose.yml"
#   if [ -d docker-data/letsencrypt/live/phpmyadmin.$ROOT_DOMAIN ]; then
#       echo "Certificate does exist for phpmyadmin"
#       (cd ../../ ; sh domain-add.sh phpmyadmin.$ROOT_DOMAIN)
#   fi
fi

# Transmission
if [[ $TRANSMISSION_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/transmission/transmission.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/transmission ] && echo "Creating docker-data/transmission directory" && mkdir $PERSISTENT_ROOT/docker-data/transmission $PERSISTENT_ROOT/docker-data/transmission/scripts $PERSISTENT_ROOT/docker-data/transmission/config $PERSISTENT_ROOT/docker-data/transmission/data

fi

# Portainer
if [[ $PORTAINER_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/portainer/portainer.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/portainer ] && echo "Creating docker-data/portainer directory" && mkdir $PERSISTENT_ROOT/docker-data/portainer

fi

# Minecraft
if [[ $MINECRAFT_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/minecraft/minecraft.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/minecraft ] && echo "Creating docker-data/minecraft directory" && mkdir $PERSISTENT_ROOT/docker-data/minecraft

fi

# Sonarr
if [[ $SONARR_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/sonarr/sonarr.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/sonarr ] && echo "Creating docker-data/sonarr directory" && mkdir $PERSISTENT_ROOT/docker-data/sonarr

fi

# Plex
if [[ $PLEX_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/plex/plex.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/plex ] && echo "Creating docker-data/plex directory" && mkdir $PERSISTENT_ROOT/docker-data/plex

   # Check if transcode tmp folder exists
   [ ! -d /tmp/transcode ] && echo "Creating /tmp/transcode directory" && mkdir /tmp/transcode

fi

# Nextcloud
if [[ $NEXTCLOUD_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nextcloud/nextcloud.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/nextcloud ] && echo "Creating docker-data/nextcloud directory" && mkdir $PERSISTENT_ROOT/docker-data/nextcloud

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/mariadb ] && echo "Creating docker-data/mariadb directory" && mkdir $PERSISTENT_ROOT/docker-data/mariadb

fi

# Collabora
if [[ $COLLABORA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/collabora/collabora.docker-compose.yml"
fi

# Octoprint
if [[ $OCTOPRINT_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/octoprint/octoprint.docker-compose.yml"
fi
