#!/bin/bash

if [[ $PERSISTENT_ROOT == "" ]]; then
   echo "Do not run this file directly, use start.sh or stop.sh"
fi

# Build string of enabled containers
DOCKER_FILES="-f docker-compose.yml"

# Samba
if [[ $SAMBA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/samba/samba.docker-compose.yml"
fi

# PHPMyAdmin
if [[ $PHPMYADMIN_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/phpmyadmin/phpmyadmin.docker-compose.yml"
   if [ -d docker-data/letsencrypt/live/phpmyadmin.$ROOT_DOMAIN ]; then
       echo "Certificate does exist for phpmyadmin"
#       (cd ../../ ; sh domain-add.sh phpmyadmin.$ROOT_DOMAIN)
   fi
fi

# Transmission
if [[ $TRANSMISSION_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/transmission/transmission.docker-compose.yml"
fi

# Portainer
if [[ $PORTAINER_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/portainer/portainer.docker-compose.yml"
fi

# Minecraft
if [[ $MINECRAFT_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/minecraft/minecraft.docker-compose.yml"
fi

# Sonarr
if [[ $SONARR_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/sonarr/sonarr.docker-compose.yml"
fi

# Plex
if [[ $PLEX_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/plex/plex.docker-compose.yml"
fi

# Nextcloud
if [[ $NEXTCLOUD_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nextcloud/nextcloud.docker-compose.yml"
fi

# Collabora
if [[ $COLLABORA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/collabora/collabora.docker-compose.yml"
fi

# Octoprint
if [[ $OCTOPRINT_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/octoprint/octoprint.docker-compose.yml"
fi
