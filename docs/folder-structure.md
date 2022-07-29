## /docker-nas/

Path to the root of the docker-nas folder. This should live in the root folder of the server. We no longer support dynamic paths so that the containers can refference the same root paths internally and reduce user confusion.

Files:
 - config.yml - This contains server configuration.


### home/

User data storage path. Also excluded from git. This directory is where apps like nextcloud and plex access stored data. You can mount additional disks and [raid](./raid.md) partitions to this folder. Example: `/docker-nas/home/4TB_HDD/`


### docker-data/

This is where apps store any persistent data. The subdirectory is the app name. This folder is excluded from git.


### docker-templates/

This is where apps store their templates. The subdirectory is the app name. This folder is excluded from git. Files belonging to an app:


```
    docker-templates/
    ├── app_name/
    │   ├── docker-compose.yml (required)
    │   ├── nginx.conf (optional)
    │   ├── .env.example (required)
    │   ├── after-start.sh (optional)
    │   └── readme.md (required)
```

#### docker-compose.yml

    This is the docker-compose.yml file for the app. It is required.

#### nginx.conf

#### .env.example

#### after-start.sh

#### readme.md

### docs/


### server/
