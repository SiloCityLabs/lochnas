#!/usr/bin/with-contenv bash

if [ -z "$SAMBA_USERMAP" ]
then
      echo "Please set a username in the form of SAMBA_USERMAP=username:userid:password,username:userid:password"
      exit 1
fi

# Read user array "username:userid:password"
IFS=',' read -r -a SAMBA_USERS <<< "$SAMBA_USERMAP"
for SAMBA_USER in "${SAMBA_USERS[@]}"
do
    IFS=':' read -r -a USER_DATA <<< "$SAMBA_USER"

    adduser -S -G xfs -u ${USER_DATA[1]} -H -D ${USER_DATA[0]}
    echo "${USER_DATA[2]}" | tee - | smbpasswd -s -c /etc/samba/smb.conf -a ${USER_DATA[0]}

done