#!/bin/ash

ARCH=`uname -m`
RED='\033[0;31m'
NC='\033[0m' # No Color

# Translate some of these to s6 supported list
if [ "$ARCH" == "armv8b" ] || [ "$ARCH" == "armv8l" ]; then
    ARCH="aarch64"
elif [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "i386" ] || [ "$ARCH" == "i686" ]; then
    ARCH="x86"
elif [ "$ARCH" == "armhf" ]; then
    ARCH="arm"
fi

STATUSCODE=$(curl --silent -L --output /tmp/s6-overlay.tar.gz --write-out "%{http_code}" https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-${ARCH}.tar.gz)

if test $STATUSCODE -eq 404; then
    echo -e "${RED}Cannot build samba, unknown architecture ${ARCH}.${NC}" 
    exit 1
fi

if test $STATUSCODE -ne 200; then
    echo -e "${RED}s6 overlay failed to download with http ${STATUSCODE} error.${NC}" 
    exit 1
fi

tar xzf /tmp/s6-overlay.tar.gz -C /
