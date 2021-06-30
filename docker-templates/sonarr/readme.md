# Sonarr container

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo. This assumes you are using plex and transmission paths.

## How to enable

Edit your `.env` file and enable this container with `SONARR_ENABLED=true` and other variables. You can access it via http://yourserverip:8989/

You can add a subdomain for easier web access but you will have to create a nginx config in docker-data/nginx/sites/sonarr.conf.template. Additionally you should enable auth in sonarr settings from the web ui.

### Additional Configuration

#### Enable root folder

Settings -> Media Management -> Root Folders -> Add Root Folder -> /tv

#### Enable Download clients

Settings -> Download Clients -> Add + -> Transmission

 - Name: `Transmission`
 - Enable: `Checked`
 - Host: `transmission.domain.com`
 - Port: `443`
 - Use SSL: `Checked`
 - Username: `<transmission username>`
 - Password: `<transmission password>`
 - Category: `sonarr`

Click test, then Save

#### Enable Indexers

Settings -> Indexers -> Add +

Select the indexer your want to enable and configure