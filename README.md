# All-In-One Docker NAS Setup V3

THIS IS A ALPHA BRANCH. DO NOT USE IT FOR PRODUCTION.

This is a docker NAS setup used to quickly get going with a private NAS and cloud setup. The purpose to keep it all dockerized is for super quick migrations in the long term future and to allow better long term updates even with an OS that is not updated as often. All containers are optional and most can easily be enabled with a boolean setting excluding nginx which is required. 

If you have v2 see this [migration guide](docs/migrating.v3.md)

### Requires
 - Ubuntu 20 server or greater is the preffered setup used for this system.
 - Domain name [ddns docs](docs/ddns.md)
 - Port forwarding 80 + 443
 - Static IP on Server, alternative is DHCP reservation on router.

### Install

#### Ubuntu/Debian

Just clone the repo and your all set. Afterwards run `./server.bin`

```
sudo apt install git
cd /
git clone https://github.com/SiloCityLabs/docker-nas.git
sudo ./server.bin -daemon install
```

#### Windows

This is untested as of right now, See issue #53 for more information.
#### OSX

This is untested as of right now, See issue #44 for more information.

### Updates

So long as you dont tamper with commited files and keep your changes inside docker-data and home you should be all set. If you need additional paths to ignore I recommend you add a local git ignore.

```
./server.bin -app update
```

### Commands

```
    server.bin -config /path/to/config/file
    server.bin -daemon
        start - Start in background
        stop - Stop background
        restart - restart in background
        install - Install as service
        uninstall - Uninstall service
    server.bin -ddns
        ip - Grab current wanip from router
        refresh - update ddns if ip changed
        force - Force update ddns ip
    server.bin -domain
        renew - Renew all domains
        add - Renew all domains, expects domain as argument
        delete - Renew all domains
    server.bin -app
        update - Update
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

Modify/create the `config.yml` and  with your settings.

### Container Docs

[Request a custom container](https://github.com/SiloCityLabs/docker-nas/issues/new?assignees=&labels=App+Request&template=app-request-template.md&title=)

Containers:
 - [Nginx + SSL + Auto Renew with certbot](docker-templates/nginx/readme.md) (web proxy + ssl)
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
 - [Prowlarr](docker-templates/prowlarr/readme.md)

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to all the creators of the docker containers listed in the compose files.
 
