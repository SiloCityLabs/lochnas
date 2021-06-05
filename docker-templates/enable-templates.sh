#!/bin/bash

if [[ $PERSISTENT_ROOT == "" ]]; then
   echo "Do not run this file directly, use start.sh or stop.sh"
fi

# Check if data folder exists
[ ! -d $PERSISTENT_ROOT/docker-data ] && echo "Creating docker-data directory" && mkdir -p $PERSISTENT_ROOT/docker-data/certbot

# Build string of enabled containers
DOCKER_FILES="-f docker-compose.yml"


NGINX_TPL=$PERSISTENT_ROOT/docker-templates/nginx/sites
NGINX_DATA=$PERSISTENT_ROOT/docker-data/nginx/sites

nginx_symlink_enable () {
   echo "Creating link for $1"
   TPL_FILE=$1.conf.template

   # If link is broken or not exists recreate
   [ -L $NGINX_DATA/$TPL_FILE ] && [ -e $NGINX_DATA/$TPL_FILE ] && ln -sf $NGINX_TPL/$TPL_FILE $NGINX_DATA/$TPL_FILE
   # If no link exists create
   [ ! -L $NGINX_DATA/$TPL_FILE ] && [ ! -e $NGINX_DATA/$TPL_FILE ] && ln -s $NGINX_TPL/$TPL_FILE $NGINX_DATA/$TPL_FILE
}
nginx_symlink_disable () {
   echo "Deleting link for $1"
   TPL_FILE=$1.conf.template
   [ -L $NGINX_DATA/$TPL_FILE ] && rm $NGINX_DATA/$TPL_FILE
}
nginx_cert_check () {
   # Check for SSL cert
   if [ ! -d docker-data/letsencrypt/live/$1.$ROOT_DOMAIN ]; then
      echo "Certificate does exist for $1.$ROOT_DOMAIN"
      echo "Run ./add-domain.sh $1.$ROOT_DOMAIN"
      exit 1
   fi
}

# ==========================
# Samba
# ==========================
if [[ $SAMBA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/samba/samba.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/samba ] && echo "Creating docker-data/samba directory" && mkdir $PERSISTENT_ROOT/docker-data/samba

   # Check if config file exists or copy it
   [ ! -f $PERSISTENT_ROOT/docker-data/samba/smb.conf ] && echo "Creating docker-data/samba/smb.conf file" && cp $PERSISTENT_ROOT/docker-templates/samba/smb.conf $PERSISTENT_ROOT/docker-data/samba/smb.conf

fi

# ==========================
# PHPMyAdmin
# ==========================
if [[ $PHPMYADMIN_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/phpmyadmin/phpmyadmin.docker-compose.yml"
   nginx_symlink_enable "phpmyadmin"
   nginx_cert_check "phpmyadmin"
else
   nginx_symlink_disable "phpmyadmin"
fi

# ==========================
# Transmission
# ==========================
if [[ $TRANSMISSION_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/transmission/transmission.docker-compose.yml"

   nginx_symlink_enable "transmission"
   nginx_cert_check "transmission"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/transmission ] && echo "Creating docker-data/transmission directory" && mkdir $PERSISTENT_ROOT/docker-data/transmission $PERSISTENT_ROOT/docker-data/transmission/scripts $PERSISTENT_ROOT/docker-data/transmission/config $PERSISTENT_ROOT/docker-data/transmission/data
else
   nginx_symlink_disable "transmission"
fi

# ==========================
# Portainer
# ==========================
if [[ $PORTAINER_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/portainer/portainer.docker-compose.yml"

   nginx_symlink_enable "portainer"
   nginx_cert_check "portainer"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/portainer ] && echo "Creating docker-data/portainer directory" && mkdir $PERSISTENT_ROOT/docker-data/portainer
else
   nginx_symlink_disable "portainer"
fi

# ==========================
# Minecraft
# ==========================
if [[ $MINECRAFT_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/minecraft/minecraft.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/minecraft ] && echo "Creating docker-data/minecraft directory" && mkdir $PERSISTENT_ROOT/docker-data/minecraft
fi

# ==========================
# Sonarr
# ==========================
if [[ $SONARR_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/sonarr/sonarr.docker-compose.yml"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/sonarr ] && echo "Creating docker-data/sonarr directory" && mkdir $PERSISTENT_ROOT/docker-data/sonarr
fi

# ==========================
# Plex
# ==========================
if [[ $PLEX_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/plex/plex.docker-compose.yml"

   # Check if data folder exists
   if [ ! -d $PERSISTENT_ROOT/docker-data/plex ]; then
      echo "Looks like plex has not been setup, please run docker-templates/plex/setup.sh tokenhere"
      exit 1
   fi

   # Check if transcode tmp folder exists
   [ ! -d /tmp/transcode ] && echo "Creating /tmp/transcode directory" && mkdir /tmp/transcode
fi

# ==========================
# Nextcloud
# ==========================
if [[ $NEXTCLOUD_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nextcloud/nextcloud.docker-compose.yml"

   nginx_symlink_enable "cloud"
   nginx_cert_check "cloud"

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/nextcloud ] && echo "Creating docker-data/nextcloud directory" && mkdir $PERSISTENT_ROOT/docker-data/nextcloud

   # Check if data folder exists
   [ ! -d $PERSISTENT_ROOT/docker-data/mariadb ] && echo "Creating docker-data/mariadb directory" && mkdir $PERSISTENT_ROOT/docker-data/mariadb
else
   nginx_symlink_disable "cloud"
fi

# ==========================
# Collabora + Onlyoffice check
# ==========================

if [ $COLLABORA_ENABLED == "true" ] && [ $ONLYOFFICE_ENABLED == "true" ]; then
   echo "Both COLLABORA_ENABLED and ONLYOFFICE_ENABLED cannot be enabled at the same time"
   exit 1
fi

# ==========================
# Collabora
# ==========================
if [[ $COLLABORA_ENABLED == "true" ]]; then
   nginx_symlink_enable "office"
   nginx_cert_check "office"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/collabora/collabora.docker-compose.yml"
else
   nginx_symlink_disable "office"
fi

# ==========================
# Onlyoffice
# ==========================
if [[ $ONLYOFFICE_ENABLED == "true" ]]; then
   nginx_symlink_enable "office"
   nginx_cert_check "office"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/onlyoffice/onlyoffice.docker-compose.yml"
else
   nginx_symlink_disable "office"
fi

# ==========================
# Octoprint
# ==========================
if [[ $OCTOPRINT_ENABLED == "true" ]]; then
   nginx_symlink_enable "octoprint"
   nginx_cert_check "octoprint"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/octoprint/octoprint.docker-compose.yml"
else
   nginx_symlink_disable "octoprint"
fi

# ==========================
# Router
# ==========================
if [[ $ROUTER_ENABLED == "true" ]]; then
   nginx_symlink_enable "router"
   nginx_cert_check "router"
else
   nginx_symlink_disable "router"
fi

# ==========================
# Home Assistant + Lan Check
# ==========================

if [ $HOMEASSISTANT_ENABLED == "true" ] && [ $HOMEASSISTANT_LAN_ENABLED == "true" ]; then
   echo "Both HOMEASSISTANT_ENABLED and HOMEASSISTANT_LAN_ENABLED cannot be enabled at the same time"
   exit 1
fi

# ==========================
# Home Assistant
# ==========================
HOMEASSISTANT_URI=http://hass
if [[ $HOMEASSISTANT_ENABLED == "true" ]]; then
   nginx_symlink_enable "hass"
   nginx_cert_check "hass"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/homeassistant/hass.docker-compose.yml"
else
   nginx_symlink_disable "hass"
fi

# ==========================
# Home Assistant LAN
# ==========================
if [[ $HOMEASSISTANT_LAN_ENABLED == "true" ]]; then
   export HOMEASSISTANT_URI=$HOMEASSISTANT_LAN_URI
   nginx_symlink_enable "hass"
   nginx_cert_check "hass"
else
   nginx_symlink_disable "hass"
fi
