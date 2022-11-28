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

Then you can create the RAID array

```
# create the raid array, using parition #1 that I just created with gdisk
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sda1 /dev/sdb1 /dev/sdd1

cat /proc/mdstat
#repeat this command and wait for 100%. It may take hours.

# verify the RAID array
# /dev/md0 (or whatever) should exist
mdadm --detail --scan

# save array. Check your location of "mdadm.conf" for your Linux distro
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u

```

After creating my RAID device you can make a partition on and use it

```
# make partition
mkfs.ext4 -F /dev/md0
# mount this manually if you want to check it
```

# Mount partition

This will work with any existing raid for a migration as well. Locate your RAID with `mdadm --detail --scan` and appemd the lines to `/etc/mdadm/mdadm.conf` like the instructions above.

Set the partition to mount on boot. Use `nano` or `vi` to add the following line to `/etc/fstab`

```
nano
```
```
/dev/md0 /lochnas/home ext4 defaults,nofail,discard 0 0
```

Make your LochNAS home directory and mount
```
mkdir -p /lochnas/home
mount -a

# verify
df -h -x devtmpfs -x tmpfs
```
