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

Do everything as root user for easier setup `sudo su`. I dont wana have to put sudo in front of literally every command.

#### Raid setup

For my setup I followed an [online guide](https://www.digitalocean.com/community/tutorials/how-to-create-raid-arrays-with-mdadm-on-ubuntu-16-04) by digital ocean to setup raid. I have a raid 5 mounted to `/mnt/raid` and another raid 5 mounted to `/mnt/plex`

#### Mount raid with fstab

This will work with any existing raid for a migration as well. All you have to do is locate your raid with `mdadm --detail --scan`.

Double check that the mdadm configuration file `/etc/mdadm/mdadm.conf` has the output of the scan in the file. If it does not you can add it like so

```
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

Now that we have located out raid drive (/dev/md0) we can mount it on every startup to `/mnt/raid` by adding the following to `/etc/fstab`.

`nano /etc/fstab`
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
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
apt update
apt install -y docker-ce docker-compose
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
./add-domain.sh cloud.domain.com
./add-domain.sh transmission.domain.com
./add-domain.sh hass.domain.com
./add-domain.sh portainer.domain.com
```

Enable autorenew `crontab -e`

```
0 0 * * 0 /path/to/renew-domain.sh
```

#### Setup plex token

Go to https://www.plex.tv/claim/ and run the command with your token to activate server.

```
./setup-plex.sh <claimcode>
```

Head over to your browser and type `http://serverip:32400/web` and if you have a response you should be all set. Finalize it by pressing `Ctrl + C`

#### Setup Samba

Edit `init.sh` and add your username and password to the file, alternatively you can make multiple users by copying the two lines.

Edit `samba/smb.conf` and change the paths, you can add as many shares as you would like.

#### Start the services

Now that we have ssl lets get started with our services.

```
./start.sh
```

#### Setup portainer

Navigate in a browser to configure nextcloud at `portainer.domain.com`. Create a username and password, then select local docker and hit next. You should be complete.

#### Setup nextcloud

Navigate in a browser to configure nextcloud at `cloud.domain.com`

First enter a personal username and password to login to nextcloud. Then before hitting next hit the advanced option.

 - Click `MySQL / MariaDB`
 - Leave data path default
 - Database User: `nextcloud`
 - Database Password: password from env.sh `MYSQL_PASSWORD=`
 - Database Name: `nextcloud`
 - Change `localhost` to `mariadb:3306`
 - Click `Next`
 
Note: If you get the error `504 Gateway timeout`, edit the file and remove `:3306` from `dbhost` and add it to `dbport` as `3306`. This is an unfortunate bug in the nextcloud installer but shouldnt be an issue past this.

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
./occ config:app:set text workspace_available --value=0
```

#### Setup Home Assistant

Navigate in a browser to configure nextcloud at `hass.domain.com`. This should be pretty straight forward.

If you get GATEWAY timeout, edit the `nginx/nginx.conf` file and change `http://hass:8123` to the gateway ip address you find inside portainer.domain.com under `network list -> raid_backend` like so `http://172.xx.0.1`.

#### Setup Transmission

This should pretty much work if you set the env.sh variables for it. You can access it via https://transmission.yourdomain.com/web/

#### Setup your cron jobs

The following crons will:
 - Update images for updates
 - Renew SSL Certificates
 - Nextcloud cron job

`crontab -e`
```
0 0 * * 0 /path/to/start.sh
0 0 * * 0 /path/to/renew-domain.sh
*/5 * * * * wget --output-document=/dev/null --quiet 'https://cloud.domain.com/cron.php'
```

#### GUI (Optional)

A friend of mine actually wanted a interface as he is not very good at linux. You can follow this [guide](https://linuxconfig.org/install-gui-on-ubuntu-server-18-04-bionic-beaver) to setup a small gui to use. I recommend Mate. I will not walk through installing this for my own server as I did not install it for myself. I preffer to keep the base OS as clean as possible.

#### Custom Transmission RSS

Inside portainer you can add your own rss feeds by making a new container like so

```
 rss:
  image: haugene/transmission-rss
  links:
    - transmission
  environment:
    - RSS_URL=http://.../xxxxx.rss
```

#### Mounting SMB on remote machines

This will not work outside of your network as the port is not forwarded. I recommend using a vpn server like the one built into Asus routers. Not recommended to port forward SMB in any scenario.

Ubuntu - https://askubuntu.com/questions/157128/proper-fstab-entry-to-mount-a-samba-share-on-boot

OSX - https://www.imore.com/how-automatically-mount-network-drives-macos

Windows - https://www.techrepublic.com/article/how-to-connect-to-linux-samba-shares-from-windows-10/

Android - https://play.google.com/store/apps/details?id=pl.solidexplorer2



## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to all the creators of the docker containers listed in the compose file.
 
