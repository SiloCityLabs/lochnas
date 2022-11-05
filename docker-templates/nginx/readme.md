# Nginx container

This container allows you to server all your containers trhough port 443 via ssl with only a single port forward set in your router.

## How to enable

Edit your `.env` file and enable this container with `NGINX_ENABLED=true` and other variables. It is recommended you set a password for auth enabled applications to use.

## Create SSL Certificates

### Add a domain

You need to use the domain argument to create SSL certificates for your nginx setup. This is highly recommended and uses Let's Encrypt for a valid certificate for free.

```
/lochnas/server.bin -domain add cloud.domain.com
```