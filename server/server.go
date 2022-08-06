package main

import (
	"flag"
	"log"
	"net/http"

	"github.com/gin-contrib/gzip"

	"server/models"
	"server/util"

	"github.com/gin-gonic/gin"

	"github.com/kardianos/service"
)

// Program structures.
//  Define Start and Stop methods.
type program struct {
	exit chan struct{}
}

func (p *program) Start(s service.Service) error {
	if service.Interactive() {
		log.Println("Running in terminal.")
	} else {
		log.Println("Running under service manager.")
	}
	p.exit = make(chan struct{})

	// Start should not block. Do the actual work async.
	go p.run()
	return nil
}
func (p *program) run() error {
	log.Printf("I'm running %v.", service.Platform())

	//Debug mode in terminal
	if !service.Interactive() || !models.Config.Server.Debug {
		gin.SetMode(gin.ReleaseMode)
	}

	// gin.DefaultWriter = io.MultiWriter(writer)
	r := gin.Default()
	r.Use(gzip.Gzip(gzip.DefaultCompression))

	apiv1 := r.Group("/api/v1")

	auth := apiv1.Group("/test")
	auth.GET("/ping", func(c *gin.Context) { c.String(200, "pong") })

	r.NoRoute(func(c *gin.Context) { c.JSON(http.StatusNotFound, gin.H{"message": "Not Found"}) })

	var err error
	models.Apps, err = models.Apps.New()
	if err != nil {
		log.Fatalln("Failed to initialize apps: " + err.Error())
	}
	log.Println(models.Apps.Start())

	go startCron()

	// Start and run the server
	log.Println("Running on http://127.0.0.1:" + models.Config.Server.Port)
	r.Run(":" + models.Config.Server.Port)

	return nil
}
func (p *program) Stop(s service.Service) error {
	// Any work in Stop should be quick, usually a few seconds at most.
	log.Println("I'm Stopping!")

	var err error
	models.Apps, err = models.Apps.New()
	if err != nil {
		log.Fatalln("Failed to initialize apps: " + err.Error())
	}
	log.Println(models.Apps.Stop())

	close(p.exit)
	return nil
}

// Service setup.
//   Define service config.
//   Create the service.
//   Handle service controls (optional).
//   Run the service.
func main() {
	//Get working dir for systemd
	path, err := util.ExecWd()
	if err != nil {
		log.Fatal(err)
	}
	models.Config.WorkingDirectory = path

	configFlag := flag.String("config", path+"/"+models.DefaultConfigPath, "Path to config file.")
	daemonFlag := flag.String("daemon", "", "Control the system service.")
	ddnsFlag := flag.String("ddns", "", "Run DDNS actions.")
	domainFlag := flag.String("domain", "", "Run domain actions.")
	appsFlag := flag.String("apps", "", "Run apps action.")
	serverFlag := flag.String("server", "", "Run server action.")
	flag.Parse()

	models.Config.Path = *configFlag

	if err := models.Config.Load(); err != nil {
		log.Fatal("Cannot load config:", err)
	}

	options := make(service.KeyValue)
	options["Restart"] = "on-success"
	options["SuccessExitStatus"] = "1 2 8 SIGKILL"
	options["WorkingDirectory"] = path
	svcConfig := &service.Config{
		Name:        "docker-nas",
		DisplayName: "Docker Nas Server and API",
		Description: "Manage docker nas containers, api and cron jobs.",
		Dependencies: []string{
			"Requires=network.target",
			"After=network-online.target syslog.target"},
		Option: options,
	}

	prg := &program{}
	s, err := service.New(prg, svcConfig)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("docker-nas open in " + path)

	//If -daemon flag is set do something
	if len(*daemonFlag) != 0 {
		err := service.Control(s, *daemonFlag)
		if err != nil {
			log.Printf("Valid actions: %q\n", service.ControlAction)
			log.Fatal(err)
		}
		return
	}
	if len(*ddnsFlag) != 0 {
		if err := action("ddns", *ddnsFlag); err != nil {
			log.Fatal(err)
		}
		return
	}
	if len(*domainFlag) != 0 {
		if err := action("domain", *domainFlag); err != nil {
			log.Fatal(err)
		}
		return
	}
	if len(*appsFlag) != 0 {
		if err := action("apps", *appsFlag); err != nil {
			log.Fatal(err)
		}
		return
	}
	if len(*serverFlag) != 0 {
		if err := action("server", *serverFlag); err != nil {
			log.Fatal(err)
		}
		return
	}

	//No flag set, lets run this
	err = s.Run()
	if err != nil {
		log.Fatal(err)
	}
}
