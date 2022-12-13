#!/bin/sh
set -e

# Update Shinobi to latest version on container start?
echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Update Shinobi to latest version on container start?"
echo "-------------------------------------------------------------------------"
if [ "$APP_UPDATE" = "auto" ]; then
    echo "Checking for Shinobi updates ..."
    git reset --hard
    git pull
    npm install
fi
echo "========================================================================="

# Install custom Node JS packages like mqtt, etc.
echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Install additional Node JS packages?"
echo "-------------------------------------------------------------------------"
if [ -n "${ADDITIONAL_NODEJS_PACKAGES}" ]; then
    echo "Install packages: ${ADDITIONAL_NODEJS_PACKAGES} ..."
    npm install ${ADDITIONAL_NODEJS_PACKAGES}
fi
echo "========================================================================="

# Create default configurations files from samples if not existing or if empty
echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Setup Shinobi default configuration?"
echo "-------------------------------------------------------------------------"
# Copy existing custom configuration files
if [ -d /config ]; then
    echo "Copy custom configuration files ..."
    cp -R -f "/config/"* /opt/shinobi || echo "No custom config files found." 
fi

if [ ! -s /opt/shinobi/conf.json ]; then
    echo "Create default config file /opt/shinobi/conf.json ..."
    cp /opt/shinobi/conf.sample.json /opt/shinobi/conf.json
fi

if [ ! -s /opt/shinobi/super.json ]; then
    echo "Create default config file /opt/shinobi/super.json ..."
    cp /opt/shinobi/super.sample.json /opt/shinobi/super.json
fi

# Issue #21: Defaults for deprecated plugins fail because of commit Shinobi-Systems/Shinobi@fd723664
if [ -d "/opt/shinobi/plugins/motion" ]; then
    if [ ! -s /opt/shinobi/plugins/motion/conf.json ]; then
        echo "Create default config file /opt/shinobi/plugins/motion/conf.json ..."
        cp /opt/shinobi/plugins/motion/conf.sample.json /opt/shinobi/plugins/motion/conf.json
    fi
fi
echo "========================================================================="

#   Update Shinobi's configuration by environment variables
echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Update Shinobi's configuration by environment variables"
echo "-------------------------------------------------------------------------"

# Set keys for CRON and PLUGINS ...
echo "Set keys for CRON and PLUGINS from environment variables ..."
if [ -n "${CRON_KEY}" ]; then
    echo "- Setting CRON key ..."
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" cron.key="${CRON_KEY}"
fi

if [ -n "${PLUGINKEY_MOTION}" ]; then
    echo "- Setting PLUGIN key ..."
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" pluginKeys.Motion="${PLUGINKEY_MOTION}"
fi

if [ -n "${PLUGINKEY_OPENCV}" ]; then
    echo "- Setting OPENCV key ..."
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" pluginKeys.OpenCV="${PLUGINKEY_OPENCV}"
fi

if [ -n "${PLUGINKEY_OPENALPR}" ]; then
    echo "- Setting OPENALPR key ..."
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" pluginKeys.OpenALPR="${PLUGINKEY_OPENALPR}"
fi

# Set configuration for motion plugin ...
# Issue #21: Defaults for deprecated plugins fail because of commit Shinobi-Systems/Shinobi@fd723664
if [ -s /opt/shinobi/plugins/motion/conf.json ]; then
    echo "- Set configuration for motion plugin from environment variables ..."
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/plugins/motion/conf.json" host="${MOTION_HOST}" port="${MOTION_PORT}" key="${PLUGINKEY_MOTION}"
fi

# Set password hash type
echo "-------------------------------------------------------------------------"
if [ -n "${PASSWORD_HASH}" ]; then
    echo "- Set password hash type to ${PASSWORD_HASH} from environment variable PASSWORD_HASH !"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" passwordType="${PASSWORD_HASH}"
fi

# Set the admin password
echo "-------------------------------------------------------------------------"
if [ -n "${ADMIN_USER}" ]; then
    if [ -n "${ADMIN_PASSWORD}" ]; then
        echo "Set the super admin credentials ..."
        # Hash the admins password
        export APP_PASSWORD_HASH=$( node -pe "require('./conf.json')['passwordType']" )
        if [ ! -n "${APP_PASSWORD_HASH}" ]; then
            export APP_PASSWORD_HASH="sha256"
        fi

        echo "  - Hash super admin password (${APP_PASSWORD_HASH})..."
        case "${APP_PASSWORD_HASH}" in
            md5)
                # MD5 hashing - unsecure!
                ADMIN_PASSWORD_HASH=$(echo -n "${ADMIN_PASSWORD}" | md5sum | sed -e 's/  -$//')
                ;;
            
            sha256)
                # SHA256 hashing
                ADMIN_PASSWORD_HASH=$(echo -n "${ADMIN_PASSWORD}" | sha256sum | sed -e 's/  -$//')
                ;;
            
            sha512)
                # SHA512 hashing with salting
                ADMIN_PASSWORD_HASH=$(echo -n "${ADMIN_PASSWORD}" | sha512sum | sed -e 's/  -$//')
                ;;

            *)
                echo "Unsupported password type ${APP_PASSWORD_HASH}. Set to md5, sha256 or sha512."
                exit 1
        esac

        # Set Shinobi's superuser's credentials
        echo "  - Set credentials ..."
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/super.json" 0.mail="${ADMIN_USER}" 0.pass="${ADMIN_PASSWORD_HASH}"
        echo "${ADMIN_USER}"
        echo "${ADMIN_PASSWORD_HASH}"
    fi
fi

echo "-------------------------------------------------------------------------"
echo "Set product type ... ${PRODUCT_TYPE}"
[ -n "${PRODUCT_TYPE}" ] && node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" productType="${PRODUCT_TYPE}"

echo "-------------------------------------------------------------------------"
echo "Set subscrpiton id ... ${SUBSCRIPTION_ID}"
[ -n "${SUBSCRIPTION_ID}" ] && node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" subscriptionId="${SUBSCRIPTION_ID}"
echo "========================================================================="

#   Set up database connection
echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Setting up database connection"
echo "-------------------------------------------------------------------------"
# Use embedded SQLite3 database ?
if [ "${EMBEDDEDDB}" = "true" ] || [ "${EMBEDDEDDB}" = "TRUE" ]; then
    echo "Prepare Shinobi to use the embedded SQLite database."
    # Create SQLite3 database if it does not exists
    chmod -R 777 /opt/dbdata

    if [ ! -e "/opt/dbdata/shinobi.sqlite" ]; then
        echo "- Creating shinobi.sqlite for SQLite3..."
        cp /opt/shinobi/sql/shinobi.sample.sqlite /opt/dbdata/shinobi.sqlite
    fi

    # Set database to SQLite3
    echo "Set database type to SQLite3 ..."
    # node /opt/shinobi/tools/modifyConfiguration.js databaseType=sqlite3 db='{"filename":"/opt/dbdata/shinobi.sqlite"}'
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" databaseType="sqlite3"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.filename="/opt/dbdata/shinobi.sqlite"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.user="DELETE"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.password="DELETE"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.host="DELETE"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.port="DELETE"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.database="DELETE"
else
    # Set database to SQLite3
    echo "Set database type to MariaDB ..."
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" databaseType="DELETE"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.filename="DELETE"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.user="${MYSQL_USER}"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.password="${MYSQL_PASSWORD}"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.host="${MYSQL_HOST}"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.port="${MYSQL_PORT}"
    node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.database="${MYSQL_DATABASE}"

    echo "Prepare Shinobi to use a MariaDB server."
    # Create MariaDB database if it does not exists
    if [ -n "${MYSQL_HOST}" ]; then
        echo -n "- Waiting for connection to MariaDB server on $MYSQL_HOST ."
        while ! mysqladmin ping -h"$MYSQL_HOST" --port="$MYSQL_PORT"; do
            sleep 1
            echo -n "."
        done
        echo " established."
    fi

    # Create MariaDB database if it does not exists
    if [ -n "${MYSQL_ROOT_USER}" ]; then
        if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
            echo "Setting up MariaDB database if it does not exists ..."

            mkdir -p sql_temp
            cp -f ./sql/framework.sql ./sql_temp
            cp -f ./sql/user.sql ./sql_temp
            cp -f ./sql/FixLdapAuth.sql ./sql_temp

            if [ -n "${MYSQL_DATABASE}" ]; then
                echo " - Set database name: ${MYSQL_DATABASE}"
                sed -i  -e "s/ccio/${MYSQL_DATABASE}/g" \
                    "./sql_temp/framework.sql"
                
                sed -i  -e "s/ccio/${MYSQL_DATABASE}/g" \
                    "./sql_temp/user.sql"

                sed -i  -e "s/ccio/${MYSQL_DATABASE}/g" \
                    "./sql_temp/FixLdapAuth.sql"
            fi

            if [ -n "${MYSQL_ROOT_USER}" ]; then
                if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
                    sed -i -e "s/majesticflame/${MYSQL_USER}/g" \
                        -e "s/''/'${MYSQL_PASSWORD}'/g" \
                        -e "s/127.0.0.1/%/g" \
                        "./sql_temp/user.sql"
                fi
            fi

            echo "- Create database schema if it does not exists ..."
            mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST --port=$MYSQL_PORT -e "source ./sql_temp/framework.sql" || true

            echo "- Fix user table for LDAP auth issues ..."
            mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST --port=$MYSQL_PORT -e "source ./sql_temp/FixLdapAuth.sql" || true

            echo "- Create database user if it does not exists ..."
            mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST --port=$MYSQL_PORT -e "source ./sql_temp/user.sql" || true

            rm -rf sql_temp
        fi
    fi

    # Set MariaDB configuration from environment variables
    echo "- Set MariaDB configuration from environment variables ..."
    if [ -n "${MYSQL_USER}" ]; then
        echo "  - MariaDB username: ${MYSQL_USER}"
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.user="${MYSQL_USER}"
    fi

    if [ -n "${MYSQL_PASSWORD}" ]; then
        echo "  - MariaDB password."
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.password="${MYSQL_PASSWORD}"
    fi

    if [ -n "${MYSQL_HOST}" ]; then
        echo "  - MariaDB server host: ${MYSQL_HOST}"
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.host="${MYSQL_HOST}"
    fi

    if [ -n "${MYSQL_PORT}" ]; then
        echo "  - MariaDB server port: ${MYSQL_PORT}"
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.port="${MYSQL_PORT}"
    fi

    if [ -n "${MYSQL_DATABASE}" ]; then
        echo "  - MariaDB database name: ${MYSQL_DATABASE}"
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" db.database="${MYSQL_DATABASE}"
    fi
fi
echo "========================================================================="

echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Applying chimps for Docker ..."
echo "-------------------------------------------------------------------------"
# Change the uid/gid of the node user
if [ -n "${GID}" ]; then
    if [ -n "${UID}" ]; then
        echo " - Set the uid:gid of the node user to ${UID}:${GID}"
        groupmod -g ${GID} node && usermod -u ${UID} -g ${GID} node
    fi
fi

# Modify Shinobi configuration
echo "- Chimp Shinobi's technical configuration ..."
cd /opt/shinobi

echo "  - Set cpuUsageMarker ..."
node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" cpuUsageMarker="%Cpu(s)"
echo "-------------------------------------------------------------------------"

# Modify YOLOv3 Plugin configuration
if [ -n "${PLUGINKEY_YOLO}" ]; then
    echo "========================================================================="
    echo "-------------------------------------------------------------------------"
    echo "        Configuring YOLOv3 Plugin ..."
    echo "-------------------------------------------------------------------------"
    echo "  - Setting YOLO Plugin key: ${PLUGINKEY_YOLO}"
        node /opt/shinobi/tools/modifyJson.js "/opt/shinobi/conf.json" pluginKeys.Yolo="${PLUGINKEY_YOLO}"
    echo "-------------------------------------------------------------------------"
fi

echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "        Ready to start Shinobi for Docker ..."
echo "-------------------------------------------------------------------------"
ffmpeg -hwaccels
echo "-------------------------------------------------------------------------"

# Execute Command
cat banner.txt
echo "is starting ... \n"

exec "$@"
