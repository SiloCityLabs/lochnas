#!/bin/bash

if [[ $GLOBAL_ROOT == "" ]]; then
   echo "Do not run this file directly, use start.sh or stop.sh"
fi

# Check if data folder exists
[ ! -d $GLOBAL_ROOT/docker-data ] && echo "Creating docker-data directory" && mkdir -p $GLOBAL_ROOT/docker-data/certbot

# Build string of enabled containers
DOCKER_FILES="-f docker-compose.yml"


NGINX_TPL=$GLOBAL_ROOT/docker-templates/nginx/sites
NGINX_DATA=$GLOBAL_ROOT/docker-data/nginx/sites

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
   # Allows us to use root domain if blank
   if [[ $1 = "" ]]; then 
      # Check for SSL cert
      if [ ! -d docker-data/letsencrypt/live/$GLOBAL_DOMAIN ]; then
         echo "Certificate does exist for $GLOBAL_DOMAIN"
         echo "Run ./domain-add.sh $GLOBAL_DOMAIN"
         exit 1
      fi
   else
      # Check for SSL cert
      if [ ! -d docker-data/letsencrypt/live/$1.$GLOBAL_DOMAIN ]; then
         echo "Certificate does exist for $1.$GLOBAL_DOMAIN"
         echo "Run ./domain-add.sh $1.$GLOBAL_DOMAIN"
         exit 1
      fi
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
   if [ ! -d $GLOBAL_ROOT/docker-data/$1 ]; then
      echo "Creating docker-data/$1 directory"
      mkdir $GLOBAL_ROOT/docker-data/$1
      return 0
   fi
   return 1
}
# Check if domain points here
checkdomain () {
    wanip="$(dig +short myip.opendns.com @resolver1.opendns.com)"

    # Allows us to use root domain if blank
    if [[ $1 == "" ]]; then 
        dnsip="$(dig +short $GLOBAL_DOMAIN @resolver1.opendns.com)"
        if [[ ! $wanip == $dnsip ]]; then
            echo "$GLOBAL_DOMAIN ($dnsip) is not pointing to your ip $wanip"
            exit 1
        fi
    else
        dnsip="$(dig +short $1.$GLOBAL_DOMAIN @resolver1.opendns.com)"
        if [[ ! $wanip == $dnsip ]]; then
            echo "$1 ($dnsip) is not pointing to your ip $wanip"
            exit 1
        fi
    fi
}


# ==========================
# NGINX
# ==========================
if [[ $NGINX_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nginx/nginx.docker-compose.yml"

   data_dir_exists "nginx"

   #Generate htpasswd
   NGINX_PASSWORD="$(openssl passwd -1 $NGINX_PASSWORD)"
   echo "$NGINX_USERNAME:$NGINX_PASSWORD" > $GLOBAL_ROOT/docker-data/nginx/.htpasswd
fi

# ==========================
# Dashboard
# ==========================
if [[ $DASHBOARD_ENABLED == "true" ]]; then
   # DOCKER_FILES=$DOCKER_FILES" -f docker-templates/dashboard/dashboard.docker-compose.yml"
   nginx_enabled
   nginx_symlink_enable "dashboard"
   nginx_cert_check ""
   checkdomain ""
else
   nginx_symlink_disable "dashboard"
fi

# ==========================
# Samba
# ==========================
if [[ $SAMBA_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/samba/samba.docker-compose.yml"

   data_dir_exists "samba" && cp $GLOBAL_ROOT/docker-templates/samba/smb.conf $GLOBAL_ROOT/docker-data/samba/smb.conf
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
   data_dir_exists "transmission" && mkdir $GLOBAL_ROOT/docker-data/transmission/scripts $GLOBAL_ROOT/docker-data/transmission/config $GLOBAL_ROOT/docker-data/transmission/data
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
# Minecraft Bedrick
# ==========================
if [[ $MINECRAFTBEDROCK_ENABLED == "true" ]]; then
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/minecraft-bedrock/minecraft-bedrock.docker-compose.yml"
   data_dir_exists "minecraft-bedrock"
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
   if [ ! -d $GLOBAL_ROOT/docker-data/plex ]; then
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
