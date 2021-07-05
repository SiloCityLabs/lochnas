#!/bin/bash

if [[ $UPDATE_RUN == "" ]]; then
   echo "Do not run this file directly, use update.sh"
   exit 1
fi

# Nginx addon
if ! grep -q NGINX_ENABLED ".env"; then
   #random password generated
   NGINX_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
   echo "Adding Nginx config to .env"
   echo "" >> .env
   echo "# NGINX" >> .env
   echo "NGINX_ENABLED=true" >> .env
   echo "NGINX_USERNAME=admin" >> .env
   echo "NGINX_PASSWORD=$NGINX_PASSWORD" >> .env
fi

# Onlyoffice addon
if ! grep -q ONLYOFFICE_ENABLED ".env"; then
   echo "Adding onlyoffice config to .env"
   echo "" >> .env
   echo "# Onlyoffice" >> .env
   echo "ONLYOFFICE_ENABLED=false" >> .env
fi

# Prowlarr addon
if ! grep -q PROWLARR_ENABLED ".env"; then
   echo "Adding Prowlarr config to .env"
   echo "" >> .env
   echo "# Prowlarr" >> .env
   echo "PROWLARR_ENABLED=false" >> .env
fi

# Radarr addon
if ! grep -q RADARR_ENABLED ".env"; then
   echo "Adding Radarr config to .env"
   echo "" >> .env
   echo "# Radarr" >> .env
   echo "RADARR_ENABLED=false" >> .env
fi

# Ark container
if ! grep -q ARK_ENABLED ".env"; then
   #random password generated
   ARK_ADMINPASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
   echo "Adding Ark config to .env"
   echo "" >> .env
   echo "# Ark" >> .env
   echo "ARK_ENABLED=false" >> .env
   echo "ARK_SESSIONNAME=Ark" >> .env
   echo "ARK_ADMINPASSWORD=$ARK_ADMINPASSWORD	" >> .env
   echo "ARK_AUTOUPDATE=120" >> .env
   echo "ARK_AUTOBACKUP=60" >> .env
   echo "ARK_WARNMINUTE=30" >> .env
   echo "ARK_SERVERMAP=TheIsland" >> .env
   echo "ARK_NBPLAYERS=20" >> .env
   echo "ARK_UPDATEONSTART=1" >> .env
   echo "ARK_BACKUPONSTART=1" >> .env
   echo "ARK_SERVERPORT=27015" >> .env
   echo "ARK_STEAMPORT=7778" >> .env
   echo "ARK_BACKUPONSTOP=0" >> .env
   echo "ARK_WARNONSTOP=0" >> .env
   echo "ARK_SERVERPASSWORD=" >> .env
fi