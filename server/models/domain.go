package models

import (
	"fmt"
	"os"
	"server/util"
)

var Domain DomainModel

//DomainModel ...
type DomainModel map[string]string

func (a DomainModel) Init() {
	// a["ip"] = env.Get("GLOBAL_DDNS_IP")
}

//Renew ssl certificate for the domains in letsencrypt config
//Needs to stop nginx and restart it after renewal
func (a DomainModel) Renew() string {

	// Check if nginx container is running in docker
	output, err := util.Command(false, Config.WorkingDirectory, nil, "docker ps -aq -f status=running -f name=nginx")
	if err != nil {
		return "Please stop nginx container in docker"
	}

	// nginx is running if the output is not empty, lets stop nginx container
	if output != "" {
		util.Command(false, Config.WorkingDirectory, nil, "docker container stop nginx")
	}

	renewCommand := "docker run --rm -i "
	renewCommand += "-v \"/docker-nas/docker-data/letsencrypt:/etc/letsencrypt\" "
	renewCommand += "-v \"/docker-nas/docker-data/certbot:/var/www/certbot\" "
	renewCommand += "-p 80:80 "
	renewCommand += "-p 443:443 "
	renewCommand += "certbot/certbot 'renew' '--standalone'"

	util.Command(false, Config.WorkingDirectory, nil, renewCommand)

	//Docker output was not empty so start it back up
	if output != "" {
		util.Command(false, Config.WorkingDirectory, nil, "docker container start nginx")
	}
	return ""
}

//TODO: Bring domain-add the fully into golang
func (a DomainModel) Add() string {
	args := os.Args[1:]

	fmt.Println(args)

	if len(args) != 3 {
		return "Please supply only one domain name like: './server.bin -domain add domain.com'"
	}

	// Check if nginx container is running in docker
	output, err := util.Command(false, Config.WorkingDirectory, nil, "docker ps -aq -f status=running -f name=nginx")
	if err != nil {
		return "Please stop nginx container in docker"
	}

	// nginx is running if the output is not empty, lets stop nginx container
	if output != "" {
		util.Command(false, Config.WorkingDirectory, nil, "docker container stop nginx")
	}

	renewCommand := "docker run --rm -i "
	renewCommand += "-v \"/docker-nas/docker-data/letsencrypt:/etc/letsencrypt\" "
	renewCommand += "-v \"/docker-nas/docker-data/certbot:/var/www/certbot\" "
	renewCommand += "-p 80:80 "
	renewCommand += "-p 443:443 "
	renewCommand += "certbot/certbot 'certonly' '--standalone' "
	renewCommand += "\"-d " + args[2] + "\" '--agree-tos' \"-m " + os.Getenv("GLOBAL_EMAIL") + "\""

	util.Command(false, Config.WorkingDirectory, nil, renewCommand)

	//Docker output was not empty so start it back up
	if output != "" {
		util.Command(false, Config.WorkingDirectory, nil, "docker container start nginx")
	}

	return ""
}

//TODO: Bring domain-remove the fully into golang
func (a DomainModel) Delete() string {

	renewCommand := "docker run --rm -i "
	renewCommand += "-v \"/docker-nas/docker-data/letsencrypt:/etc/letsencrypt\" "
	renewCommand += "-v \"/docker-nas/docker-data/certbot:/var/www/certbot\" "
	renewCommand += "certbot/certbot 'delete'"

	util.Command(false, Config.WorkingDirectory, nil, renewCommand)
	return ""
}
