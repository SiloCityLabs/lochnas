#!/bin/bash

if [[ $PERSISTENT_ROOT == "" ]]; then
   echo "Do not run this file directly, use update.sh"
fi

# Onlyoffice addon
if ! grep -q ONLYOFFICE_ENABLED ".env"; then
   echo "Adding onlyoffice config to .env"
   echo "" >> .env
   echo "# Onlyoffice" >> .env
   echo "ONLYOFFICE_ENABLED=false" >> .env
fi

# Ark container
if ! grep -q ARK_ENABLED ".env"; then
   echo "Adding Ark config to .env"
   echo "" >> .env
   echo "# Ark" >> .env
   echo "ARK_ENABLED=false" >> .env
   echo "ARK_SESSIONNAME=Ark" >> .env
   echo "ARK_ADMINPASSWORD=password	" >> .env
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