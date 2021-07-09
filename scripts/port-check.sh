#!/bin/bash

PORTCHECKBIN=./scripts/port-check/port-check.$(dpkg --print-architecture).bin

# Check if port 80 is open
$PORTCHECKBIN --port 80 --ip $wanip
if [ ! $? -eq 0 ]; then
    echo "Failed to access port 80, please check your routers port forwarding"
    exit 1
fi

# Check if port 443 is open
$PORTCHECKBIN --port 443 --ip $wanip
if [ ! $? -eq 0 ]; then
    echo "Failed to access port 443, please check your routers port forwarding"
    exit 1
fi

if [[ $PLEX_ENABLED == "true" ]]; then
    # Check if port 32400 is open
    $PORTCHECKBIN --port 32400 --ip $wanip
    if [ ! $? -eq 0 ]; then
        echo "Failed to access port 32400, please check your routers port forwarding"
        exit 1
    fi
fi