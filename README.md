# All-In-One Docker NAS Setup

This is a docker nas setup used to quickly get going with a private nas and cloud setup. The purpose to keep it all dockerized is for super quick migrations in the long term future and to allow better long term updates in the even that the OS is not updated as often. 

Requires:
 - Domain name
 - Port forwarding 80 + 443
 - Static IP on Server, alternative is DHCP reservation on router.

Includes:
 - Transmission + VPN (Torrents, Requires VPN)
 - Nextcloud (Private cloud)
 - MariaDB MySQL (for Nextcloud)
 - Nginx + SSL (Web Proxy + SSL)
 - Home Assistant (Home Automation)
 - Portainer (Quickly add more docker containers)
 - Plex

Upcomming
 - Samba (Local file share)
 - Auto Renew SSL with certbot

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

#### Mount raid with fstab

This will work with any existing raid for a migration as well. All you have to do is locate your raid with `mdadm --detail --scan`.

Double check that the mdadm configuration file `/etc/mdadm/mdadm.conf` has the output of the scan in the file. If it does not you can add it like so

```
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

Now that we have located out raid drive (/dev/md0) we can mount it on every startup to `/mnt/raid` by adding the following to `/etc/fstab`.

`sudo nano /etc/fstab`
```
/dev/md0 /mnt/raid ext4 defaults,nofail,discard 0 0
```

Last and finally make the folder and mount the drive.

```
mkdir /mnt/raid
mount -a
```

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

#### Create users and groups

We will be using the www-data user to share permissions between services. You can make seperate users and groups if you would like to but I found that this is easiest way to manage access accross the board.

```
id www-data
```
Grab the id given by the last command to use in your configs.

uid=`33`(www-data) gid=`33`(www-data)

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

Modify the `env.sh` with your settings, Transmission on this setup is used with a vpn service.

Modify `nginx/nginx.conf` and replace all instances of `domain.com` with your domain name.

Modify `samba/smb.conf`.


#### Create SSL Certificates

You will need to use the add-domain.sh script to create some SSL certificates for your nginx setup. This is highly recommended and uses letsencrypt for a valid certificate for free.

```
sudo ./add-domain.sh cloud.domain.com
sudo ./add-domain.sh transmission.domain.com
sudo ./add-domain.sh hass.domain.com
sudo ./add-domain.sh portainer.domain.com
```

#### Setup plex token

Go to https://www.plex.tv/claim/ and run the command with your token to activate server.

```
sudo ./setup-plex.sh <claimcode>
```

Head over to your browser and type `http://serverip:32400/web` and if you have a response you should be all set. Finalize it by pressing `Ctrl + C`

#### Start the services

Now that we have ssl lets get started with our services.

```
sudo ./start.sh
```

#### Setup portainer

Navigate in a browser to configure nextcloud at `portainer.domain.com`. Create a username and password, then select local docker and hit next. You should be complete.

#### Setup nextcloud

Navigate in a browser to configure nextcloud at `cloud.domain.com`

You will need the credentials you created for the `env.sh` to configure nextcloud. Database name being nextcloud and user nextcloud, hostname will be `mariadb`.

After you get to the welcome screen go to settings -> basic settings. Change the cron settings to webcron.

You will need to make some tweaks to improve this nextcloud docker setup. Head over 

 1. Portainer
 2. Containers
 3. Click console icon for nextcloud under Quick column
 4. User: www-data
 5. Connect

Type the following commands:

```
./occ db:add-missing-indices
./occ db:convert-filecache-bigint
```

#### Setup Home Assistant

Navigate in a browser to configure nextcloud at `hass.domain.com`. This should be pretty straight forward.


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

#### GUI (Optional)

A friend of mine actually wanted a interface as he is not very good at linux. You can follow this [guide](https://linuxconfig.org/install-gui-on-ubuntu-server-18-04-bionic-beaver) to setup a small gui to use. I recommend Mate. I will not walk through installing this for my own server as I did not install it for myself. I preffer to keep the base OS as clean as possible.

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to all the creators of the docker containers listed in the compose file.
 