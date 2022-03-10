package main

import (
	"errors"
	"log"

	"server/models"
)

func action(action string, param string) error {
	switch action {
	case "domain":
		switch param {
		case "renew":
			log.Println("domain renew")
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
		models.Apps = make(models.AppsModel, 0) //[]AppModel{}
		models.Apps.Init()

		switch param {
		case "start":
			log.Println(models.Apps.Start())
		case "test":
			log.Println(models.Apps.Start())
		case "update":
			log.Println(models.Apps.Update())
		default:
			return errors.New("Invalid option try -app [update]")
		}
	}

	return nil
}
