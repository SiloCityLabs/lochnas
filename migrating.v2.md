# Migrate from v1 to v2 docker nas with git pull support

### Update docker

Because of new features in docker-compose we need to make sure to use the latest docker otherwise it may fail to startup.

```
apt update
apt dist-upgrade
do-release-upgrade
```

### Open directory and shutdown

```bash
cd /mnt/raid
docker-compose down
```

### Move old container data into new structure

```bash
mkdir docker-data
mv homeassistant docker-data/
mkdir docker-data/nextcloud
mv nextcloud docker-data/nextcloud/html
mv mariadb docker-data/
mv plex docker-data/
mv portainer docker-data/
mv samba docker-data/
mv sonarr docker-data/
mv transmission docker-data/
mv nginx docker-data/
mv certbot docker-data/
mv letsencrypt docker-data/
mkdir docker-data/nginx/logs
```
### Delete uneeded scripts and files

```bash
rm -f docker-compose.yml
rm -f start.sh
rm -f add-domain.sh
rm -rf .git
rm -f renew-domain.sh
rm -f setup-plex.sh
```

### Clone repo and move new files

```bash
git clone https://github.com/SiloCityLabs/docker-nas.git
mv docker-nas/* ./
mv -f docker-nas/{.,}* ./
rm -rf docker-nas
```

### Make a home directory

Make a home directory and move any remaining folders if you dont already have one. `home` is already a gitignored folder path

```bash
mkdir home
mv somefolder home/
```

### Copy template env

```bash
cp .env.example .env
```

Now edit and carry over env.sh configs

### Copy over some other configs

```
cp docker-templates/nextcloud/policy.xml docker-data/nextcloud/
```
