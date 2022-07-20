package main

import (
	"errors"
	"log"

	"server/models"
)

func action(action string, param string) error {
	switch action {
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
	}

	return nil
}
