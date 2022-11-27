# RAID setup

For ldrrp's setup he followed an [online guide](https://www.digitalocean.com/community/tutorials/how-to-create-raid-arrays-with-mdadm-on-ubuntu-16-04) by DigitalOcean to setup raid. He has a RAID 5 mounted to `/lochnas` and another raid 5 mounted to `/lochnas/home/plex`

Maave also set up RAID 5 but had issues with the DigitalOcean guide - he needed to use partitions for RAID to persist. Here are the command examples. His RAID drives are A B and D. 

Use a disk utility to create partitions and mark the drive for RAID auto-detect. Partition type `fd00` is the magic hex code for RAID auto-detect

```
# make a GPT partition and mark as RAID.
# Check partitions ('p' command) before writing ('w' command)
# Repeat for each RAID drive.
gdisk /dev/sda
    n
    {enter}
    {enter}
    {enter}
    fd00
    p
    w
    y
```

Then you can create the RAID array with MDADM and proceed as normal

```
# create the raid array, using parition #1 that I just created with gdisk
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sda1 /dev/sdb1 /dev/sdd1

cat /proc/mdstat
#repeat this command and wait for 100%. It may take hours.

# verify the RAID array
mdadm --detail --scan

# make partition
mkfs.ext4 -F /dev/md0
# mount partition
mount /dev/md0 /docker-nas/home
# verify
df -h -x devtmpfs -x tmpfs

#save array. Check the location of "mdadm.conf" for your Linux distro
mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
update-initramfs -u

# update /etc/fstab so that it mounts on boot
#/dev/md0 /docker-nas/home ext4 defaults,nofail,discard 0 0

```



## Mount raid with fstab

This will work with any existing raid for a migration as well. All you have to do is locate your raid with `mdadm --detail --scan`.

Double check that the mdadm configuration file `/etc/mdadm/mdadm.conf` has the output of the scan in the file. If it does not you can add it like so

```
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

Now that we have located out raid drive (/dev/md0) we can mount it on every startup to `/lochnas` by adding the following to `/etc/fstab`.

`nano /etc/fstab`
```
/dev/md0 /lochnas ext4 defaults,nofail,discard 0 0
```

Last and finally make the folder and mount the drive.

```
mkdir /lochnas
mount -a
```
