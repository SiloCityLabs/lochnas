# Plex Container

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo.

Original maintainer [plexinc/pms-docker](https://hub.docker.com/r/plexinc/pms-docker)

## How to enable

Edit your `.env` file and enable this container with `PLEX_ENABLED=true`

Go to https://www.plex.tv/claim/ to grab your claim code to be used for the command below.

ENter your token into .env variable PLEX_CLAIM

Head over to your browser and type `http://serverip:32400/web` and if you have a response you should be all set. Finalize it by pressing `Ctrl + C`

You can comment or remove the PLEX_CLAIM variable now.

### Additional Configuration

`PLEX_DATA=/docker-nas/home/plex` - Path to plex media directory mounted inside plex as `/docker-nas/home`