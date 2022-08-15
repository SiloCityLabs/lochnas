# Nextcloud

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo.

Original maintainer [Nextcloud](https://hub.docker.com/_/nextcloud), [mariadb](https://hub.docker.com/_/mariadb)

## How to enable

Edit your `.env` file and enable this container then run `./start.sh`

```
NEXTCLOUD_ENABLED=false
NEXTCLOUD_DATA=/docker-nas/home
MYSQL_ROOT_PASSWORD=password
MYSQL_PASSWORD=password
```

#### Setup nextcloud

Navigate in a browser to configure nextcloud at `cloud.domain.com`

First enter a personal username and password to login to nextcloud. Then before hitting next hit the advanced option.

 - Click `MySQL / MariaDB`
 - Leave data path default
 - Database User: `nextcloud`
 - Database Password: password from .env `MYSQL_PASSWORD=`
 - Database Name: `nextcloud`
 - Change `localhost` to `mariadb:3306`
 - Click `Next`
 
Note: If you get the error `504 Gateway timeout`, edit the file and remove `:3306` from `dbhost` and add it to `dbport` as `3306`. This is an unfortunate bug in the nextcloud installer but shouldnt be an issue past this.

After you get to the welcome screen go to settings -> basic settings. Change the cron settings to webcron. 

Go to apps and disable the app called `Deleted Files`. This application causes issues with `External Storage` plugin.

Go to External storage in settings and create a storage under /raid for your users.

You will need to make some tweaks to improve this nextcloud docker setup. Type the following commands:

```
docker exec -it nextcloud ./occ db:add-missing-indices
docker exec -it nextcloud ./occ db:convert-filecache-bigint
docker exec -it nextcloud ./occ config:app:set text workspace_available --value=0
```

Make one last addition to the config file to fix a login redirect issue.

`nano docker-data/nextcloud/html/config/config.php`
```
  'overwrite.cli.url' => 'https://cloud.yourdomain.com',
  'overwritehost' => 'cloud.yourdomain.com',
  'overwriteprotocol' => 'https',
```