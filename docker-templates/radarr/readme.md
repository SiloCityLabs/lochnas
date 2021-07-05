# Radarr container

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo. This assumes you are using plex and transmission paths.

## How to enable

Edit your `.env` file and enable this container with `RADARR_ENABLED=true` and other variables. You can access it via https://radarr.yourdomain.com

To use web access you must have nginx auth password set

### Additional Configuration

#### Enable root folder

Settings -> Media Management -> Root Folders -> Add Root Folder -> /movies

#### Enable Download clients

Settings -> Download Clients -> Add + -> Transmission

 - Name: `Transmission`
 - Enable: `Checked`
 - Host: `transmission.domain.com`
 - Port: `443`
 - Use SSL: `Checked`
 - Username: `<transmission username>`
 - Password: `<transmission password>`
 - Category: `radarr`

Click test, then Save

#### Enable Indexers

Settings -> Indexers -> Add +

Select the indexer your want to enable and configure