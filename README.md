# All-In-One Docker NAS Setup V2

This is a docker NAS setup used to quickly get going with a private NAS and cloud setup. The purpose to keep it all dockerized is for super quick migrations in the long term future and to allow better long term updates even with an OS that is not updated as often. All containers are optional and most can easily be enabled with a boolean setting excluding nginx which is required. 

If you have v1 see this [migration guide](docs/migrating.v2.md)

### Requires
 - Ubuntu 20 server or greater is the preffered setup used for this system.
 - Domain name [ddns docs](docs/ddns.md)
 - Port forwarding 80 + 443
 - Static IP on Server, alternative is DHCP reservation on router.

### Install

Just clone the repo and your all set. Afterwards run `./start.sh`
```
git clone https://github.com/SiloCityLabs/docker-nas.git
./start.sh
```

### Updates

So long as you dont tamper with commited files and keep your changes inside docker-data and home you should be all set. If you need additional paths to ignore I recommend you add a local git ignore.

```
./update.sh
```

### Prerequisites

Do everything as root user for easier setup `sudo su`. Or put sudo in front of every command. 

#### Create users and groups

We will be using the www-data user to share permissions between services. You can make seperate users and groups if you would like to but I found that this is the easiest way to manage access accross the board.

You can give your user access to any files of www-data with this command.

```
usermod -aG www-data yourusername
```

If you need to access the local folder mounted in the compose file at `/raid` from nextcloud local storage plugin, you can run the following set of commands on a folder to grant permission:

```
chown -R www-data:www-data path/to/local
chmod -R 770 path/to/local
```

#### Edit config

Modify the `.env` with your settings.

#### Create SSL Certificates

You need to use the add-domain.sh script to create SSL certificates for your nginx setup. This is highly recommended and uses Let's Encrypt for a valid certificate for free.

```
./add-domain.sh cloud.domain.com
```

Enable autorenew by adding a cron with `crontab -e`

```
0 0 * * 0 /path/to/renew-domain.sh
```

### Container Docs

Required containers:
 - Nginx + SSL + Auto Renew with certbot (Web Proxy + SSL)

Optional containers:
 - [Transmission + VPN](docker-templates/transmission/readme.md) (Torrents, Requires VPN)
 - [Nextcloud + MariaDB](docker-templates/nextcloud/readme.md) (Private cloud)
 - [Home Assistant](docker-templates/homeassistant/readme.md) (Home Automation)
 - [Portainer](docker-templates/portainer/readme.md) (Quickly add more docker containers)
 - [Plex](docker-templates/plex/readme.md)
 - [Samba](docker-templates/samba/readme.md) (Local file share)
 - [Minecraft](docker-templates/minecraft/readme.md)
 - [Ark](docker-templates/ark/readme.md)
 - [PHPMyAdmin](docker-templates/phpmyadmin/readme.md)
 - [Sonarr](docker-templates/sonarr/readme.md)
 - [Radarr](docker-templates/radarr/readme.md)

#### Start the services

```
./start.sh
```
#### Setup your cron jobs

Create a Renew SSL Certificates cron

`crontab -e`
```
0 0 * * 0 /path/to/renew-domain.sh
```

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to all the creators of the docker containers listed in the compose files.
 
