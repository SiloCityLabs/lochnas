#!/bin/bash

#x Step 1: load all the variables from .env 
#x Step 2: create folder docker-data/v3
#x Step 3: create docker-data/v3/.env.global 
#x Step 4: create docker-data/v3/.env.{app_alias}
#x Step 5: switch to v3 branch (Test with luis)
#x Step 6: Replace all the .envs to the new paths
#x Step 7: Remove crons related to domain renewal
#x Step 8: Remove crons related to start.sh
#x Step 9: Run damen installer
#x Step 10: welcome to v3 message with link to docs

cd "$(dirname "$0")"

# Load env variables
source .env

./stop.sh
docker network prune

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
echo "HOMEASSISTANT_ENABLED=$HOMEASSISTANT_ENABLED" >  $HOMEASSISTANT_ENV

#SAMBA ENV
SAMBA_ENV=docker-data/v3/.env.samba
echo "SAMBA_ENABLED=$SAMBA_ENABLED" > $SAMBA_ENV
echo "SAMBA_USERMAP=$SAMBA_USERMAP" >> $SAMBA_ENV

#Sonarr ENV
SONARR_ENV=docker-data/v3/.env.sonarr
echo "SONARR_ENABLED=$SONARR_ENABLED" > $SONARR_ENV

#PHPmyadmin ENV
PHPMYADMIN_ENV=docker-data/v3/.env.phpmyadmin
echo "PHPMYADMIN_ENABLED=$PHPMYADMIN_ENABLED" > $PHPMYADMIN_ENV

#Collabora ENV
COLLABORA_ENV=docker-data/v3/.env.collabora
echo "COLLABORA_ENABLED=$COLLABORA_ENABLED" > $COLLABORA_ENV

#Onlyoffice ENV
ONLYOFFICE_ENV=docker-data/v3/.env.onlyoffice
echo "ONLYOFFICE_ENABLED=$ONLYOFFICE_ENABLED" > $ONLYOFFICE_ENV

#Ark ENV
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

#NGINX ENV
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

#Homeassistant LAN
if [[ $HOMEASSISTANT_LAN_ENABLED == "true" ]]; then
    echo "HOMEASSISTANT_LAN_ENABLED This feature has been moved to manual templates. See docker-templates/nginx/sites-available/"
fi

#Octoprint LAN
if [[ $OCTOPRINT_ENABLED == "true" ]]; then
    echo "OCTOPRINT_ENABLED This feature has been moved to manual templates. See docker-templates/nginx/sites-available/"
fi

#Router Proxy LAN
if [[ $ROUTER_ENABLED == "true" ]]; then
    echo "ROUTER_ENABLED This feature has been moved to manual templates. See docker-templates/nginx/sites-available/"
fi

# Remove crons
crontab -l | grep -v "0 0 \* \* 0 $PERSISTENT_ROOT/renew-domain.sh" | crontab -
crontab -l | grep -v "0 0 \* \* 0 $PERSISTENT_ROOT/start.sh" | crontab -

echo "Edit your crontab -e and move any ddns into config.yml manually"

git checkout v3

cp .env .env.backup
cp $GLOBAL_ENV .env
cp $ARK_ENV docker-templates/ark/.env
cp $COLLABORA_ENV docker-templates/collabora/.env
cp $HOMEASSISTANT_ENV docker-templates/homeassistant/.env
cp $MINECRAFT_ENV docker-templates/minecraft/.env
cp $NEXTCLOUD_ENV docker-templates/nextcloud/.env
cp $NGINX_ENV docker-templates/nginx/.env
cp $ONLYOFFICE_ENV docker-templates/onlyoffice/.env
cp $PHPMYADMIN_ENABLED docker-templates/phpmyadmin/.env
cp $PLEX_ENV docker-templates/plex/.env
cp $PORTAINER_ENV docker-templates/portainer/.env
cp $PROWLARR_ENV docker-templates/prowlarr/.env
cp $RADARR_ENV docker-templates/radarr/.env
cp $SAMBA_ENV docker-templates/samba/.env
cp $SONARR_ENV docker-templates/sonarr/.env
cp $TRANSMISSION_ENV docker-templates/transmission/.env

echo "############################################################"
echo "###               Welcome to docker-nas v3               ###"
echo "###    Please check over all your .env files then run    ###"
echo "###      Create config.yml from config.example.yml       ###"
echo "###          ./server.bin -daemon install                ###"
echo "###           ./server.bin -daemon start                 ###"
echo "###                                                      ###"
echo "###  https://github.com/SiloCityLabs/docker-nas/tree/v3  ###"
echo "############################################################"
