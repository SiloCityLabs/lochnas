# Transmission

This is a template to add this container to your nas setup full functional with matching permissions and settings that of docker-nas repo.


## How to enable

Edit your `.env` file and enable this container with `TRANSMISSION_ENABLED=true` and other variables. You can access it via https://transmission.yourdomain.com/web/

The other variables are require with this vpn only transmission container.

## Custom Transmission RSS

Inside portainer you can add your own rss feeds by making a new container like so

```
 rss:
  image: haugene/transmission-rss
  links:
    - transmission
  environment:
    - RSS_URL=http://.../xxxxx.rss
```