package main

import (
	"log"
	"server/models"

	"github.com/robfig/cron"
)

func startCron() {
	c := cron.New()

	//Check if ddns config is empty
	if len(models.Config.Server.DDNS.URL) != 0 {
		c.AddFunc("0 */5 * * * *", func() { // Every 5 mins
			log.Println("Triggering -ddns refresh")
			models.DDNS = make(models.DDNSModel)
			models.DDNS.Init()
			log.Println(models.DDNS.Refresh())
		})
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