#!/usr/bin/with-contenv sh

#xfs = 33 for www-data in this docker image

#First user
adduser -S -G xfs -H -D username
echo "password" | tee - | smbpasswd -s -c /etc/samba/smb.conf -a username
