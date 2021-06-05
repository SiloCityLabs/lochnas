# All-In-One Docker NAS Setup

This is a docker nas setup used to quickly get going with a private nas and cloud setup. The purpose to keep it all dockerized is for super quick migrations in the long term future and to allow better long term updates in the even that the OS is not updated as often. 

If you have v1 see this [migration guide](docs/migrating.v2.md)

### Requires
 - Ubuntu 20 server or greater is the preffered setup used for this system.
 - Domain name [ddns docs](docs/ddns.md)
 - Port forwarding 80 + 443
 - Static IP on Server, alternative is DHCP reservation on router.

### Prerequisites

Do everything as root user for easier setup `sudo su`. I dont wana have to put sudo in front of literally every command.

#### Create users and groups

We will be using the www-data user to share permissions between services. You can make seperate users and groups if you would like to but I found that this is easiest way to manage access accross the board.

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

You will need to use the add-domain.sh script to create some SSL certificates for your nginx setup. This is highly recommended and uses letsencrypt for a valid certificate for free.

```
./add-domain.sh cloud.domain.com
```

Enable autorenew by adding a cron with `crontab -e`

```
0 0 * * 0 /path/to/renew-domain.sh
```

### Container Docs
 - Nginx + SSL + Auto Renew with certbot (Web Proxy + SSL)
 - [Transmission + VPN](docker-templates/transmission/readme.md) (Torrents, Requires VPN)
 - [Nextcloud + MariaDB](docker-templates/nextcloud/readme.md) (Private cloud)
 - [Home Assistant](docker-templates/homeassistant/readme.md) (Home Automation)
 - [Portainer](docker-templates/portainer/readme.md) (Quickly add more docker containers)
 - [Plex](docker-templates/plex/readme.md)
 - [Samba](docker-templates/samba/readme.md) (Local file share)
 - [Minecraft](docker-templates/minecraft/readme.md)
 - [PHPMyAdmin](docker-templates/phpmyadmin/readme.md)

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
 
