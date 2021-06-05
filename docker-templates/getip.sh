#!/bin/bash

wanip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
hostname="$(hostname)"

# port80= [ $(wget http://$wanip/.status -q -O -) == "ok!" ]
# echo $port80

#port443=

# if [[ $PLEX_ENABLED == "true" ]]; then
   
# fi