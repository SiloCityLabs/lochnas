package main

import (
	"log"
	"server/models"

	"github.com/robfig/cron/v3"
)

func startCron() {
	c := cron.New(cron.WithSeconds())

	//Check if ddns config is empty
	if len(models.Config.Server.DDNS.URL) != 0 && models.Config.Server.DDNS.Enabled {
		c.AddFunc("0 */5 * * * *", func() { // Every 5 mins
			log.Println("Triggering -ddns refresh")
			models.DDNS = make(models.DDNSModel)
			models.DDNS.Init()
			log.Println(models.DDNS.Refresh())
		})
	}

	//Updates enabled so lets call it
	if models.Config.Server.Updates.Enabled {
		//Make sure expression is valid
		if _, err := cron.ParseStandard(models.Config.Server.Updates.Cron); err != nil {
			log.Println("Failed to parse cron expression for updates: " + err.Error())
		} else {
			c.AddFunc(models.Config.Server.Updates.Cron, func() {
				log.Println("Triggering -app update")
				log.Println(models.Apps.Update())
			})
		}
	}

	//Restart the docker containers so they update
	c.AddFunc("0 0 6 * * 0", func() { // 6AM Sundays
		log.Println("Triggering start()")
		var err error
		models.Apps, err = models.Apps.New()
		if err != nil {
			log.Fatalln("Failed to initialize apps: " + err.Error())
		}
		log.Println(models.Apps.Start())
	})

	//domain ssl renewal
	c.AddFunc("0 2 5 * * 0", func() { // 5:02AM Sundays
		log.Println("Triggering Renew()")
		models.Domain = make(models.DomainModel)
		log.Println(models.Domain.Renew())
	})

	c.Start()
}
