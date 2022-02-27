package main

import (
	"log"
	"server/models"
	"server/util"

	"github.com/robfig/cron"
)

func startCron() {
	c := cron.New()

	c.AddFunc("0 */5 * * * *", func() { // Every 5 mins
		log.Println("Triggering -ddns refresh")
		models.DDNS.Refresh()
	})

	c.AddFunc("0 0 6 * * 0", func() { // 6AM Sundays
		log.Println("Triggering start.sh")
		util.Command(false, models.Config.WorkingDirectory, nil, "./start.sh")
	})

	c.AddFunc("0 2 5 * * 0", func() { // 5:02AM Sundays
		log.Println("Triggering start.sh")
		util.Command(false, models.Config.WorkingDirectory, nil, "./domain-renew.sh")
	})

	// c.AddFunc("* * * * * *", func() { log.Println("Every second") })

	c.Start()
}
