# DDNS setup

You need your domain name to point to your IP address. This is done by visiting an "Update URL" (sometimes "Dynamic URL"). Go to your domain provider's website and find the URL for your domain. The random value at the end is your **secret API key**. Do not share it and do not save it in git.

example update URL:

```
https://ipv4.cloudns.net/api/dynamicURL/?q=abcdefghijklmnopqrstuvwxyz1234567890987654321zyxwvutsrqponmlkjihgfedcba
```

Edit _config.yml_. Go to the _ddns_ section, change _enabled_ to true, and add your update URL. Ignore the IP value - LochNAS will populate it automatically. 

```
    ddns:
        ip: 0.0.0.0
        enabled: true
        url:
            - https://ipv4.cloudns.net/api/dynamicURL/?q=abcdefghijklmnopqrstuvwxyz1234567890987654321zyxwvutsrqponmlkjihgfedcba
        notification:
            enabled: false
            service: telegram

```

Then run

```
service lochnas restart
```

Done! LochNAS will automatically update your DDNS every few minutes.

# Alternative #1: cron 
You can use cron to update the DDNS. Edit the crontab file with `crontab -e`. Add a command that visits your Update URL like this:

```
0 6 * * * wget --output-document=/dev/null --quiet 'https://dnsprovider.com/updateurl?key=somekey'
```

# Alternative #2: Docker (figure it out)

If your DNS provider doesn't provide Update URLs then I recommend searching the Docker repository for a DDNS updater. Add the Docker image using Portainer. We can't help you much here.
