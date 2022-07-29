# Home Assistant

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo.

Original maintainer [homeassistant/home-assistant](https://hub.docker.com/r/homeassistant/home-assistant)

## How to enable

Edit your `.env` file and enable this container with `HOMEASSISTANT_ENABLED=true`. Run `./start.sh` and navigate in a browser to configure nextcloud at `hass.domain.com`. This should be pretty straight forward.

## Adding dongle to container

To add a zigbee/zwave dongle to the container, you need to add the device path to your `.env` file:

Example:
```
DEVICE_0=/dev/ttyUSB0
DEVICE_1=/dev/ttyUSB1
DEVICE_2=/dev/null
DEVICE_3=/dev/null
```