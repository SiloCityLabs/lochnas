# All-In-One LochNAS Setup

This is a docker NAS setup used to quickly get going with a private NAS and cloud setup. The purpose to keep it all dockerized is for super quick migrations in the long term future and to allow better long term updates even with an OS that is not updated as often. All containers are optional and most can easily be enabled with a boolean setting excluding nginx which is required. 

[Install LochNAS](https://lochnas.com/docs/install/)

## Requires
 - Ubuntu 20 server or greater is the preffered setup used for this system.
 - [Port forwarding](https://portforward.com/router.htm) 80 + 443
 - Static IP on Server, alternative is [DHCP reservation](https://portforward.com/dhcp-reservation/#how-to-make-a-dhcp-reservation-in-your-router) on router.

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to all the creators of the docker containers listed in the compose files.
 
