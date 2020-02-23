# All-In-One Docker NAS Setup

This is a docker nas setup used to quickly get going with a private nas and cloud setup. The purpose to keep it all dockerized is for super quick migrations in the long term future and to allow better long term updates in the even that the OS is not updated as often. 

Requires:
 - Domain name
 - Port forwarding 80 + 443
 - Static IP on Server, alternative is DHCP reservation on router.

Includes:
 - Transmission (Torrents)
 - Nextcloud (Private cloud)
 - Nginx + SSL (Web Proxy + SSL)
 - Home Assistant (Home Automation)
 - Portainer (Quickly add more docker containers)
 - Plex

Upcomming
 - Samba (Local file share)

## Getting Started

Ubuntu 18.04 LTS server is the preffered setup used for this system. You may use anything else at your own risk. If you dont want any of the docker containers feel free to remove them from both `nginx/nginx.conf` and `docker-compose.yml`

### Prerequisites

#### Kill snaps (optional)

We will not be using snap at all for this setup so lets kill it and speed up the boot time in the process.

```
sudo apt purge snapd
```

#### Raid setup

For my setup I followed an [online guide](https://www.digitalocean.com/community/tutorials/how-to-create-raid-arrays-with-mdadm-on-ubuntu-16-04) by digital ocean to setup raid. I have a raid 5 mounted to `/mnt/raid` and another raid 5 mounted to `/mnt/plex`

#### Install docker

If you have done so already you will need to install docker and docker compose to get this working. If you skip this the `start.sh` script will attempt to do this. However I suggest doing this first manually since you will need it for creating ssl certificates. This set of commands will ensure you have the latest docker directly from the official repo.

```
sudo apt install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt update
sudo apt install -y docker-ce docker-compose
```

#### DDNS setup

You will need to make sure your domain is pointing to your IP address before moving on to the next step for ssl. We can setup a ddns cronjob easily if you have an update url available.

Edit your crontab file `crontab -e` and add the following with your update url

```
0 6 * * * wget --output-document=/dev/null --quiet 'https://dnsprovider.com/updateurl?key=somekey'
```

If you dont have a provider with an update url I recommend searching the docker repository and adding one using portainer afterwards. In the meantime just point your domain manually.

### Installing

#### Edit config

Modify the `env.sh` with your settings, Transmission on this setup is used with a vpn service.

Modify nginx/nginx.conf and replace all instances of `domain.com` with your domain name.

#### Create SSL Certificates

You will need to use the add-domain.sh script to create some SSL certificates for your nginx setup. This is highly recommended and uses letsencrypt for a valid certificate for free.

```
sudo ./add-domain.sh cloud.domain.com
sudo ./add-domain.sh transmission.domain.com
sudo ./add-domain.sh hass.domain.com
sudo ./add-domain.sh portainer.domain.com
```

#### Setup plex token

Go to https://plex.tv/link and run the command with your token to activate server.

```
sudo ./setup-plex.sh
```

#### Start the services

Now that we have ssl lets get started with our services.

```
sudo ./start.sh
```

#### Setup nextcloud

You will need the credentials you created for the `env.sh` to configure nextcloud. Database name being nextcloud and user nextcloud.

After you get to the welcome screen go to settings -> basic settings. Change the cron settings to webcron.

#### Setup your cron jobs

The following crons will:
 - Update images for updates
 - Renew SSL Certificates
 - Nextcloud cron job

```
0 0 * * 0 /path/to/start.sh
0 0 * * 0 /path/to/renew-domain.sh
*/5 * * * * wget --output-document=/dev/null --quiet 'https://cloud.domain.com/cron.php'

```

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to all the creators of the docker containers
 