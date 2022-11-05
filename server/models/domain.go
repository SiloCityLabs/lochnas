package models

import (
	"io/ioutil"
	"log"
	"os"
	"server/util"
)

var Domain DomainModel

// DomainModel ...
type DomainModel map[string]string

var SSLPath string = "/lochnas/docker-data/letsencrypt/live/"

func (a DomainModel) Init() {
	// a["ip"] = env.Get("GLOBAL_DDNS_IP")
}

// Renew ssl certificate for the domains in letsencrypt config
// Needs to stop nginx and restart it after renewal
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
	renewCommand += "-v \"/lochnas/docker-data/letsencrypt:/etc/letsencrypt\" "
	renewCommand += "-v \"/lochnas/docker-data/certbot:/var/www/certbot\" "
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

func (a DomainModel) Add() string {
	args := os.Args[1:]

	log.Println(args)

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
	renewCommand += "-v \"/lochnas/docker-data/letsencrypt:/etc/letsencrypt\" "
	renewCommand += "-v \"/lochnas/docker-data/certbot:/var/www/certbot\" "
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

func (a DomainModel) Delete() string {

	renewCommand := "docker run --rm -i "
	renewCommand += "-v \"/lochnas/docker-data/letsencrypt:/etc/letsencrypt\" "
	renewCommand += "-v \"/lochnas/docker-data/certbot:/var/www/certbot\" "
	renewCommand += "certbot/certbot 'delete'"

	util.Command(false, Config.WorkingDirectory, nil, renewCommand)
	return ""
}

// This will check if the existing certs are valid.
func (a DomainModel) Check() string {

	// Scan directory for domains
	files, err := ioutil.ReadDir(SSLPath)
	if err != nil {
		return "Error scanning directory"
	}

	for _, file := range files {
		log.Println(file.Name())

		// Check if file is not a directory
		if !file.IsDir() {
			continue
		}

		// Validate the certificate
		if err := util.VerifyCert(SSLPath+file.Name()+"/fullchain.pem", SSLPath+file.Name()+"/cert.pem", file.Name()); err != nil {
			log.Println("Error validating certificate for " + file.Name() + ": " + err.Error())
			//We dont need to error out, we just need to let the user know. App checker will verify it has the ones it needs.

			if Config.Server.SSL.Notification.Enabled {
				Config.Server.Notifications.Notify(Config.Server.SSL.Notification.Service, "Error validating certificate for "+file.Name()+": "+err.Error())
			}
		}
	}

	return ""
}
