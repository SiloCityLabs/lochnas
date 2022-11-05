# Portainer

This is a template to add this container to your nas setup full functional with matching permissions and settings that of lochnas repo.

Original maintainer [portainer/portainer-ce](https://hub.docker.com/r/portainer/portainer-ce)

## How to enable

Edit your `.env` file and enable this container with `PORTAINER_ENABLED=true`

After running `./start.sh` navigate in a browser to configure at `portainer.domain.com`. Create a username and password, then select local docker and hit next. You should be complete.