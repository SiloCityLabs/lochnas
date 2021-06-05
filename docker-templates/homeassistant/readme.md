# Home Assistant

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo.


## How to enable

Edit your `.env` file and enable this container with `HOMEASSISTANT_ENABLED=true`. Run `./start.sh` and navigate in a browser to configure nextcloud at `hass.domain.com`. This should be pretty straight forward.

## Run home assistant on a seperate machine

Edit your `.env` file and enable this container with `HOMEASSISTANT_LAN_ENABLED=true` and `HOMEASSISTANT_LAN_URI=http://iptohassio:8123`. Run `./start.sh` and navigate in a browser to configure nextcloud at `hass.domain.com`. This should be pretty straight forward. You cannot run both at the same time.