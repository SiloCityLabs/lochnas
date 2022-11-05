nano /etc/fstab (edit this file)
service docker-nas stop
systemctl disable docker-nas
mkdir lochnas
rm -rf /etc/systemd/system/docker-nas.service
reboot
rm -rf docker-nas
docker rm -f $(docker ps -a -q)
docker image prune -f
docker network prune -f
docker volume prune -f
./server.bin -daemon install
service lochnas start
docker image prune -a

rename nextcloud mount points
probably have to reconfigure transmission, prowlarr, radarr and sonarr mount points as well