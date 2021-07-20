# Prowlarr container

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo. This assumes you are using plex and transmission paths.

## How to enable

Edit your `.env` file and enable this container with `PROWLARR_ENABLED=true` and other variables. You can access it via https://prowlarr.yourdomain.com

To use web access you must have nginx auth password set

#### Enable Download clients

Settings -> Download Clients -> Add + -> Transmission

 - Name: `Transmission`
 - Enable: `Checked`
 - Host: `transmission.domain.com`
 - Port: `443`
 - Use SSL: `Checked`
 - Username: `<transmission username>`
 - Password: `<transmission password>`
 - Category: `prowlarr`

Click test, then Save

#### Enable Indexers

Indexers -> Add New Indexer

Select the indexer your want to enable and configure

#### Enable Applications

Settings -> Apps -> Add Application

 - Prowlarr Server
   - Replace localhost with prowlarr
 - Sonarr Server
   - Replace localhost with sonarr
 - Radarr Server
   - Replace localhost with radarr
