package main

import (
	"errors"
	"log"

	"server/models"
)

func action(action string, param string) error {
	switch action {
	case "daemon": //This runs before the systemd daemon installer
		models.Daemon = make(models.DaemonModel)
		models.Daemon.Init()

		switch param {
		case "install":
			log.Println(models.Daemon.Install())
		case "uninstall":
			log.Println(models.Daemon.Uninstall())
		}
	case "domain":
		models.Domain = make(models.DomainModel)
		models.Domain.Init()

		switch param {
		case "add":
			log.Println(models.Domain.Add())
		case "delete":
			log.Println(models.Domain.Delete())
		case "renew":
			log.Println(models.Domain.Renew())
		default:
			return errors.New("Invalid option try -domain [renew]")
		}
	case "ddns":
		models.DDNS = make(models.DDNSModel)
		models.DDNS.Init()

		switch param {
		case "ip":
			log.Println(models.DDNS.WanIp())
		case "refresh":
			log.Println(models.DDNS.Refresh())
		case "force":
			log.Println(models.DDNS.Force())
		default:
			return errors.New("Invalid option try -ddns [refresh, ip, ip-info]")
		}
	case "apps":
		var err error
		models.Apps, err = models.Apps.New()
		if err != nil {
			log.Fatalln("Failed to initialize apps: " + err.Error())
		}

		switch param {
		case "start":
			log.Println(models.Apps.Start())
		case "stop":
			log.Println(models.Apps.Stop())
		case "test":
			log.Println(models.Apps.Test())
		case "update":
			log.Println(models.Apps.Update())
		default:
			return errors.New("Invalid option try -app [update]")
		}
	case "server":
		switch param {
		case "notify":
			log.Println(models.Config.Server.Notifications.Test())
		}
	case "disks":
		var err error
		models.Disks, err = models.Disks.Init()
		if err != nil {
			log.Fatalln("Failed to initialize disks: " + err.Error())
		}

		switch param {
		case "list":
			log.Println(models.Disks.List())
		}
	}

	return nil
}
