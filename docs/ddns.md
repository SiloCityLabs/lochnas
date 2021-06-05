# DDNS setup

You will need to make sure your domain is pointing to your IP address before moving on to the next step for ssl. We can setup a ddns cronjob easily if you have an update url available.

Edit your crontab file `crontab -e` and add the following with your update url

```
0 6 * * * wget --output-document=/dev/null --quiet 'https://dnsprovider.com/updateurl?key=somekey'
```

If you dont have a provider with an update url I recommend searching the docker repository and adding one using portainer afterwards. In the meantime just point your domain manually.