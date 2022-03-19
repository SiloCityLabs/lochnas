package main

import (
	"log"
	"server/models"

	"github.com/robfig/cron"
)

func startCron() {
	c := cron.New()

	c.AddFunc("0 */5 * * * *", func() { // Every 5 mins
		log.Println("Triggering -ddns refresh")
		models.DDNS.Refresh()
	})

	c.AddFunc("0 0 6 * * 0", func() { // 6AM Sundays
		log.Println("Triggering start()")
		var err error
		models.Apps, err = models.Apps.New()
		if err != nil {
			log.Fatalln("Failed to initialize apps: " + err.Error())
		}
		log.Println(models.Apps.Start())
	})

	//TODO: domain renewal stuff
	// c.AddFunc("0 2 5 * * 0", func() { // 5:02AM Sundays
	// 	log.Println("Triggering domain-renew.sh")
	// 	util.Command(false, models.Config.WorkingDirectory, nil, "./scripts/domain-renew.sh")
	// })

	// c.AddFunc("* * * * * *", func() { log.Println("Every second") })

	c.Start()
}
