#!/bin/bash

# Step 1: load all the variables from .env 
# Step 2: create folder docker-data/v3
# Step 3: create docker-data/v3/.env.global 
#     - look at v3 for what to throw in files
# Step 4: create docker-data/v3/.env.{app_alias}
#     - look at v3 for what to throw in files
# Step 5: switch to v3 branch (Test with luis)
# Step 6: Replace all the .envs to the new paths
# Step 7: Remove crons related to domain renewal
#   - Learn how to read/edit crontab
# Step 8: Remove crons related to start.sh
# Step 9: Run damen installer
# Step 10: welcome to v3 message with link to docs

cd "$(dirname "$0")"

# Load env variables
source .env

mkdir -p docker-data/v3

re="[[:space:]]+"

#Global ENV
GLOBAL_ENV=docker-data/v3/.env.global
echo "GLOBAL_DOMAIN=$ROOT_DOMAIN" > $GLOBAL_ENV
echo "GLOBAL_EMAIL=$LE_EMAIL" >> $GLOBAL_ENV
echo "GLOBAL_GID=$PGID" >> $GLOBAL_ENV
echo "GLOBAL_UID=$PUID" >> $GLOBAL_ENV
if [[ $PERSISTENT_ROOT =~ $re ]]; then
echo "GLOBAL_ROOT=\"$PERSISTENT_ROOT\"" >> $GLOBAL_ENV
else
echo "GLOBAL_ROOT=$PERSISTENT_ROOT" >> $GLOBAL_ENV
fi
echo "GLOBAL_TZ=America/New_York" >> $GLOBAL_ENV

#Transmission ENV
TRANSMISSION_ENV=docker-data/v3/.env.transmission
echo "TRANSMISSION_ENABLED=$TRANSMISSION_ENABLED" > $TRANSMISSION_ENV
echo "OPENVPN_PASSWORD=\"$OPENVPN_PASSWORD\"" >> $TRANSMISSION_ENV
echo "OPENVPN_USERNAME=$OPENVPN_USERNAME" >> $TRANSMISSION_ENV
echo "OPENVPN_PROVIDER=$OPENVPN_PROVIDER" >> $TRANSMISSION_ENV
echo "NORDVPN_COUNTRY=$NORDVPN_COUNTRY" >> $TRANSMISSION_ENV
echo "TRANSMISSION_RPC_USERNAME=$TRANSMISSION_RPC_USERNAME" >> $TRANSMISSION_ENV
echo "TRANSMISSION_RPC_PASSWORD=\"$TRANSMISSION_RPC_PASSWORD\"" >> $TRANSMISSION_ENV

#Plex ENV
PLEX_ENV=docker-data/v3/.env.plex
echo "PLEX_ENABLED=$PLEX_ENABLED" > $PLEX_ENV
if [[ $PLEX_DATA =~ $re ]]; then
echo "PLEX_DATA=\"$PLEX_DATA\"" >> $PLEX_ENV
else
echo "PLEX_DATA=$PLEX_DATA" >> $PLEX_ENV
fi

#Nextcloud ENV
NEXTCLOUD_ENV=docker-data/v3/.env.nextcloud
echo "NEXTCLOUD_ENABLED=$NEXTCLOUD_ENABLED" > $NEXTCLOUD_ENV
echo "NEXTCLOUD_DATA=$NEXTCLOUD_DATA" >> $NEXTCLOUD_ENV
echo "MYSQL_ROOT_PASSWORD=\"$MYSQL_ROOT_PASSWORD\"" >> $NEXTCLOUD_ENV
echo "MYSQL_PASSWORD=\"$MYSQL_PASSWORD\"" >> $NEXTCLOUD_ENV

#Minecraft ENV
MINECRAFT_ENV=docker-data/v3/.env.minecraft
echo "MINECRAFT_ENABLED=$MINECRAFT_ENABLED" > $MINECRAFT_ENV

#Portainer ENV
PORTAINER_ENV=docker-data/v3/.env.portainer
echo "PORTAINER_ENABLED=$PORTAINER_ENABLED" > $PORTAINER_ENV

#Homeassistant ENV
HOMEASSISTANT_ENV=docker-data/v3/.env.homeassistant
echo "HOMEASSISTANT_ENABLED=$HOMEAwelcome to v3 message with link to docs
SAMBA_ENV=docker-data/v3/.env.samba
echo "SAMBA_ENABLED=$SAMBA_ENABLED" > $SAMBA_ENV
echo "SAMBA_USERMAP=$SAMBA_USERMAP" >> $SAMBA_ENV

#Sonarr ENV
SONARR_ENV=docker-data/v3/.env.sonarr
echo "SONARR_ENABLED=$SONARR_ENABLED" > $SONARR_ENV

#PHPmyadmin ENV
PHPMYADMIN_ENV=docker-data/v3/.env.phpmyadmin
echo "PHPMYADMIN_ENABLED=$PHPMYADMIN_ENABLED" > $PHPMYADMIN_ENV

#Collabora ENVwelcome to v3 message with link to docsCE_ENABLED" > $ONLYOFFICE_ENV

#Ark Proxy LAN ENV
ARK_ENV=docker-data/v3/.env.ark
echo "ARK_ENABLED=$ARK_ENABLED" > $ARK_ENV
if [[ $ARK_SESSIONNAME =~ $re ]]; then
echo "ARK_SESSIONNAME=\"$ARK_SESSIONNAME\"" >> $ARK_ENV
else
echo "ARK_SESSIONNAME=$ARK_SESSIONNAME" >> $ARK_ENV
fi
echo "ARK_ADMINPASSWORD=\"$ARK_ADMINPASSWORD\"" >> $ARK_ENV
echo "ARK_AUTOUPDATE=$ARK_AUTOUPDATE" >> $ARK_ENV
echo "ARK_AUTOBACKUP=$ARK_AUTOBACKUP" >> $ARK_ENV
echo "ARK_WARNMINUTE=$ARK_WARNMINUTE" >> $ARK_ENV
if [[ $ARK_SERVERMAP =~ $re ]]; then
echo "ARK_SERVERMAP=\"$ARK_SERVERMAP\"" >> $ARK_ENV
else
echo "ARK_SERVERMAP=$ARK_SERVERMAP" >> $ARK_ENV
fi
echo "ARK_NBPLAYERS=$ARK_NBPLAYERS" >> $ARK_ENV
echo "ARK_UPDATEONSTART=$ARK_UPDATEONSTART" >> $ARK_ENV
echo "ARK_BACKUPONSTART=$ARK_BACKUPONSTART" >> $ARK_ENV
echo "ARK_SERVERPORT=$ARK_SERVERPORT" >> $ARK_ENV
echo "ARK_STEAMPORT=$ARK_STEAMPORT" >> $ARK_ENV
echo "ARK_BACKUPONSTOP=$ARK_BACKUPONSTOP" >> $ARK_ENV
echo "ARK_WARNONSTOP=$ARK_WARNONSTOP" >> $ARK_ENV
echo "ARK_SERVERPASSWORD=\"$ARK_SERVERPASSWORD\"" >> $ARK_ENV

#NGINX Proxy LAN ENV
NGINX_ENV=docker-data/v3/.env.nginx
echo "NGINX_ENABLED=$NGINX_ENABLED" > $NGINX_ENV
echo "NGINX_USERNAME=$NGINX_USERNAME" >> $NGINX_ENV
echo "NGINX_PASSWORD=\"$NGINX_PASSWORD\"" >> $NGINX_ENV

#Prowlarr ENV
PROWLARR_ENV=docker-data/v3/.env.prowlarr
echo "PROWLARR_ENABLED=$PROWLARR_ENABLED" > $PROWLARR_ENV

#Radarr ENV
RADARR_ENV=docker-data/v3/.env.radarr
echo "RADARR_ENABLED=$RADARR_ENABLED" > $RADARR_ENV

### LAN Config ###
LAN_CONFIG=docker-data/v3/config.yml

#Homeassistant LAN
echo "HOMEASSISTANT_LAN_ENABLED=$HOMEASSISTANT_LAN_ENABLED" > $LAN_CONFIG
echo -e "HOMEASSISTANT_LAN_URI=$HOMEASSISTANT_LAN_URI\n" >> $LAN_CONFIG

#Octoprint Proxy LAN
echo "OCTOPRINT_ENABLED=$OCTOPRINT_ENABLED" >> $LAN_CONFIG
echo -e "OCTOPRINT_PATH=$OCTOPRINT_PATH\n" >> $LAN_CONFIG

#Router Proxy LAN
echo "ROUTER_ENABLED=$ROUTER_ENABLED" >> $LAN_CONFIG
echo "ROUTER_PATH=$ROUTER_PATH" >> $LAN_CONFIG

# Remove crons
# crontab -l | grep -v "0 0 \* \* 0 $PERSISTENT_ROOT/renew-domain.sh" | crontab -
# crontab -l | grep -v "0 0 \* \* 0 $PERSISTENT_ROOT/start.sh" | crontab -


#Add cron back
# line="0 0 * * 0 $PERSISTENT_ROOT/start.sh"
# (crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
