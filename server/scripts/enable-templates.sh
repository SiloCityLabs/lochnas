#!/bin/bash

# THIS SCRIPT WILL EVENTUALLY MOVE INTO GOLANG
echo "DONT RUN"
exit 1

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
   DOCKER_FILES=$DOCKER_FILES" -f docker-templates/nginx/docker-compose.yml"

   data_dir_exists "nginx"

   #Generate htpasswd
   NGINX_PASSWORD="$(openssl passwd -1 $NGINX_PASSWORD)"
   echo "$NGINX_USERNAME:$NGINX_PASSWORD" > $GLOBAL_ROOT/docker-data/nginx/.htpasswd
fi
