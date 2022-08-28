#!/bin/bash

if [ "$HONEYGAIN_TERMS_ACCEPT" == "true" ]; then
	./honeygain -tou-accept -email "${HONEYGAIN_EMAIL}" -pass "${HONEYGAIN_PASSWORD}" -device "${HONEYGAIN_DEVICE_NAME}"
else
    ./honeygain -tou-get
	echo "Please accept the Terms of service in the .env file"
fi