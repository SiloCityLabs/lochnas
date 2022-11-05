# Samba Windows File Share

This is a template to add this container to your nas setup full functional with matching permissions and settings that of lochnas repo.


## How to enable

Edit your `.env` file and enable this container with `SAMBA_ENABLED=true`

Create a usermap for windows file share to login, This is the linux username and linux user id on your host machine. You can get your user id with the `id -u username` command.

```
SAMBA_USERMAP=username:1001:password,username:1002:password
```

### Additional Configuration

On first run it will create a default `smb.conf` from the templates directory. Afterwards you can edit `docker-data/samba/smb.conf` and change the paths, you can add as many shares as you would like.

## Mounting SMB on remote machines

This will not work outside of your network as the port is not forwarded. I recommend using a vpn server like the one built into Asus routers. Not recommended to port forward SMB in any scenario.

Ubuntu - https://askubuntu.com/questions/157128/proper-fstab-entry-to-mount-a-samba-share-on-boot

OSX - https://www.imore.com/how-automatically-mount-network-drives-macos

Windows - https://www.techrepublic.com/article/how-to-connect-to-linux-samba-shares-from-windows-10/

Android - https://play.google.com/store/apps/details?id=pl.solidexplorer2
