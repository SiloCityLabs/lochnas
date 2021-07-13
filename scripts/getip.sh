#!/bin/bash

wanip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
hostname="$(hostname)"

# Check if domain points here
checkdomain() {
    # Allows us to use root domain if blank
    if [[ $1 == "" ]]; then 
        dnsip="$(dig +short $ROOT_DOMAIN @resolver1.opendns.com)"
        if [[ ! $wanip == $dnsip ]]; then
            echo "$ROOT_DOMAIN is not pointing to your ip"
            exit 1
        fi
    else
        dnsip="$(dig +short $1.$ROOT_DOMAIN @resolver1.opendns.com)"
        if [[ ! $wanip == $dnsip ]]; then
            echo "$1 is not pointing to your ip"
            exit 1
        fi
    fi


} 
