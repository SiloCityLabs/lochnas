# Raid setup

For my setup I followed an [online guide](https://www.digitalocean.com/community/tutorials/how-to-create-raid-arrays-with-mdadm-on-ubuntu-16-04) by digital ocean to setup raid. I have a raid 5 mounted to `/mnt/raid` and another raid 5 mounted to `/mnt/plex`

## Mount raid with fstab

This will work with any existing raid for a migration as well. All you have to do is locate your raid with `mdadm --detail --scan`.

Double check that the mdadm configuration file `/etc/mdadm/mdadm.conf` has the output of the scan in the file. If it does not you can add it like so

```
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

Now that we have located out raid drive (/dev/md0) we can mount it on every startup to `/mnt/raid` by adding the following to `/etc/fstab`.

`nano /etc/fstab`
```
/dev/md0 /mnt/raid ext4 defaults,nofail,discard 0 0
```

Last and finally make the folder and mount the drive.

```
mkdir /mnt/raid
mount -a
```