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
      echo "Run ./domain-add.sh $1.$ROOT_DOMAIN"
      exit 1
   fi
}
nginx_enabled () {
   if [[ ! $NGINX_ENABLED == "true" ]]; then
      echo "Must have NGINX enabled for web based containers"
      exit 1
   fi
}
data_dir_exists () {
   # Check if data folder exists
   if [ ! -d $PERSISTENT_ROOT/docker-data/$1 ]; then
      echo "Creating docker-data/$1 directory"
      mkdir $PERSISTENT_ROOT/docker-data/$1
      return 0
   fi
   return 1
}

# ==========================
# NGINX
# ==========================
if [[ $NGINX_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nginx/nginx.docker-compose.yml"

   data_dir_exists "nginx"

   #Generate htpasswd
   NGINX_PASSWORD="$(openssl passwd -1 $NGINX_PASSWORD)"
   echo "$NGINX_USERNAME:$NGINX_PASSWORD" > $PERSISTENT_ROOT/docker-data/nginx/.htpasswd
fi

# ==========================
# Samba
# ==========================
if [[ $SAMBA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/samba/samba.docker-compose.yml"

   data_dir_exists "samba" && cp $PERSISTENT_ROOT/docker-templates/samba/smb.conf $PERSISTENT_ROOT/docker-data/samba/smb.conf
fi

# ==========================
# PHPMyAdmin
# ==========================
if [[ $PHPMYADMIN_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/phpmyadmin/phpmyadmin.docker-compose.yml"
   nginx_enabled
   nginx_symlink_enable "phpmyadmin"
   nginx_cert_check "phpmyadmin"
   checkdomain "phpmyadmin"
else
   nginx_symlink_disable "phpmyadmin"
fi

# ==========================
# Transmission
# ==========================
if [[ $TRANSMISSION_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/transmission/transmission.docker-compose.yml"
   nginx_enabled
   nginx_symlink_enable "transmission"
   nginx_cert_check "transmission"
   checkdomain "transmission"

   # Check if data folder exists
   data_dir_exists "transmission" && mkdir $PERSISTENT_ROOT/docker-data/transmission/scripts $PERSISTENT_ROOT/docker-data/transmission/config $PERSISTENT_ROOT/docker-data/transmission/data
else
   nginx_symlink_disable "transmission"
fi

# ==========================
# Portainer
# ==========================
if [[ $PORTAINER_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/portainer/portainer.docker-compose.yml"
   nginx_enabled
   nginx_symlink_enable "portainer"
   nginx_cert_check "portainer"
   checkdomain "portainer"
   data_dir_exists "portainer"
else
   nginx_symlink_disable "portainer"
fi

# ==========================
# Minecraft
# ==========================
if [[ $MINECRAFT_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/minecraft/minecraft.docker-compose.yml"
   data_dir_exists "minecraft"
fi

# ==========================
# Ark
# ==========================
if [[ $ARK_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/ark/ark.docker-compose.yml"
   data_dir_exists "ark"
fi

# ==========================
# Sonarr
# ==========================
if [[ $SONARR_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/sonarr/sonarr.docker-compose.yml"
   data_dir_exists "sonarr"
   nginx_enabled
   nginx_symlink_enable "sonarr"
   nginx_cert_check "sonarr"
   checkdomain "sonarr"
fi

# ==========================
# Radarr
# ==========================
if [[ $RADARR_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/radarr/radarr.docker-compose.yml"
   data_dir_exists "radarr"
   nginx_enabled
   nginx_symlink_enable "radarr"
   nginx_cert_check "radarr"
   checkdomain "radarr"
fi

# ==========================
# Prowlarr
# ==========================
if [[ $PROWLARR_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/prowlarr/prowlarr.docker-compose.yml"
   data_dir_exists "prowlarr"
   nginx_enabled
   nginx_symlink_enable "prowlarr"
   nginx_cert_check "prowlarr"
   checkdomain "prowlarr"
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
   nginx_enabled
   nginx_symlink_enable "cloud"
   nginx_cert_check "cloud"
   checkdomain "cloud"
   data_dir_exists "nextcloud"
   data_dir_exists "mariadb"
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
   nginx_enabled
   nginx_symlink_enable "office"
   nginx_cert_check "office"
   checkdomain "office"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/collabora/collabora.docker-compose.yml"
else
   nginx_symlink_disable "office"
fi

# ==========================
# Onlyoffice
# ==========================
if [[ $ONLYOFFICE_ENABLED == "true" ]]; then
   nginx_enabled
   nginx_symlink_enable "office"
   nginx_cert_check "office"
   checkdomain "office"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/onlyoffice/onlyoffice.docker-compose.yml"
else
   nginx_symlink_disable "office"
fi

# ==========================
# Octoprint
# ==========================
if [[ $OCTOPRINT_ENABLED == "true" ]]; then
   nginx_enabled
   nginx_symlink_enable "octoprint"
   nginx_cert_check "octoprint"
   checkdomain "octoprint"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/octoprint/octoprint.docker-compose.yml"
else
   nginx_symlink_disable "octoprint"
fi

# ==========================
# Router
# ==========================
if [[ $ROUTER_ENABLED == "true" ]]; then
   nginx_enabled
   nginx_symlink_enable "router"
   nginx_cert_check "router"
   checkdomain "router"
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
   nginx_enabled
   nginx_symlink_enable "hass"
   nginx_cert_check "hass"
   checkdomain "hass"
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/homeassistant/hass.docker-compose.yml"
else
   nginx_symlink_disable "hass"
fi

# ==========================
# Home Assistant LAN
# ==========================
if [[ $HOMEASSISTANT_LAN_ENABLED == "true" ]]; then
   export HOMEASSISTANT_URI=$HOMEASSISTANT_LAN_URI
   nginx_enabled
   nginx_symlink_enable "hass"
   nginx_cert_check "hass"
   checkdomain "hass"
else
   nginx_symlink_disable "hass"
fi
