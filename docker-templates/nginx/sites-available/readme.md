### Alternative sites available for use

These config files allow you to route internal network traffic via nginx. These are samples and you can make your own as well. You can either use the predefined variables or add your own. All configs must be set via nginx/.env

#### Enabling a custom site

Create a `appname.conf.example` file in `/lochnas/docker-data/nginx/templates/`.

#### Using a custom template below

Create a copy in the sites folder then edit your file or add the .env variables to nginx app.

```
cp homeassistant_lan.conf.templates ../../docker-data/nginx/templates/
```

