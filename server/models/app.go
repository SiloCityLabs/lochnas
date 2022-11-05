package models

import (
	"errors"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"server/util"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

var Apps AppsModel

type AppsModel []AppModel

// AppModel ...
type AppModel struct {
	// Folder name of the app
	Name string
	// App path
	Path string
	// Is the app enabled
	Enabled bool
	// Has after-start.sh file
	AfterStart bool
	// Has before-start.sh file
	BeforeStart bool
	// Has nginx.conf file
	Nginx       bool
	NginxLinked bool
	//Nginx server_name
	ServerName string
	// ENV Variables
	ENV map[string]string
}

func (a AppsModel) New() (AppsModel, error) {
	tplPath := Config.WorkingDirectory + "/docker-templates/"
	dataPath := Config.WorkingDirectory + "/docker-data/"

	files, err := ioutil.ReadDir(tplPath)
	if err != nil {
		log.Println(err)
		return a, err
	}

	for _, f := range files {
		//Only look at folders
		if f.IsDir() {
			app := AppModel{
				Name:    f.Name(),
				Path:    tplPath + f.Name() + "/",
				Enabled: false,
			}

			//Check docker-compose.yml
			if _, err := os.Stat(app.Path + "docker-compose.yml"); err != nil {
				if Config.Server.Debug {
					log.Println("Could not find " + app.Path + "docker-compose.yml")
				}
				continue
			}

			//Check .env
			if _, err := os.Stat(app.Path + ".env"); err == nil {
				//ENV To check for
				envName := strings.ToUpper(strings.ReplaceAll(app.Name, "-", "_")) + "_ENABLED"

				// Is app enabled?
				app.ENV, err = godotenv.Read(app.Path + ".env")
				if err != nil {
					return nil, errors.New("Could not read " + app.Path + ".env: " + err.Error())
				}

				if val, ok := app.ENV[envName]; ok && val == "true" {
					app.Enabled = true

					//Load its global_ variables
					for envKey, envValue := range app.ENV {
						if strings.HasPrefix(strings.ToLower(envKey), "global_") {
							os.Setenv(envKey, envValue)
						}
					}
				}
			}

			//Check if nginx.conf exists for apps other than nginx
			if app.Name != "nginx" {
				if _, err := os.Stat(app.Path + "nginx.conf"); err == nil {
					app.Nginx = true

					//get server_name
					out, err := util.Command(true, app.Path, nil, "grep -m1 -Poe 'server_name \\K[^; ]+' nginx.conf")
					if err != nil {
						return nil, errors.New("Could not get server_name from " + app.Path + "nginx.conf: " + err.Error())
					}

					//Replace env variables and trim whitespace
					app.ServerName = strings.TrimSpace(strings.Replace(out, "${GLOBAL_DOMAIN}", os.Getenv("GLOBAL_DOMAIN"), -1))

					if Config.Server.Debug {
						log.Println("Found " + app.Path + "nginx.conf: " + app.ServerName)
					}

					//check if ssl is valid
					// Validate the certificate
					if app.ServerName == "" {
						log.Println("server_name is not valid for " + app.Name)
						if Config.Server.SSL.Notification.Enabled {
							Config.Server.Notifications.Notify(Config.Server.SSL.Notification.Service, "server_name is not valid for "+app.Name)
						}
					} else if app.Enabled {
						if err := util.VerifyCert(SSLPath+app.ServerName+"/fullchain.pem", SSLPath+app.ServerName+"/cert.pem", app.ServerName); err != nil {
							log.Println("Error validating app certificate for " + SSLPath + app.ServerName + ": " + err.Error())

							if Config.Server.SSL.Notification.Enabled {
								Config.Server.Notifications.Notify(Config.Server.SSL.Notification.Service, "Error validating app certificate for "+app.ServerName+": "+err.Error())
							}
						}
					}
				}
			}

			//Check if nginx.conf is already copied over
			if _, err := os.Stat(dataPath + "nginx/templates/" + app.Name + ".apps.conf.template"); err == nil {
				app.NginxLinked = true
			}

			//Check before-start.sh
			if _, err := os.Stat(app.Path + "before-start.sh"); err == nil {
				app.BeforeStart = true
			}

			//Check after-start.sh
			if _, err := os.Stat(app.Path + "after-start.sh"); err == nil {
				app.AfterStart = true
			}

			a = append(a, app)
		} else {
			log.Println("Something does not look right about this apps folder (" + tplPath + f.Name() + "/" + "), see folder structure documentation here: https://github.com/SiloCityLabs/lochnas/blob/v3/docs/folder-structure.md")
		}
	}

	return a, nil
}

func (a AppsModel) Test() string {

	return ""
}

func (a AppsModel) Update() string {
	log.Println("Checking for updates...")

	//Check for updates
	out, err := util.Command(true, Config.WorkingDirectory, nil, "git pull")
	if err != nil {
		log.Println("Error updating: " + err.Error())
		return "Error updating: " + err.Error()
	}
	out = strings.TrimSpace(out)

	//Remove whitespace from out
	if out == "Already up to date." {
		return out
	}

	//New updates so let the user know we have to reboot
	if Config.Server.Updates.Notification.Enabled {
		Config.Server.Notifications.Notify(Config.Server.Updates.Notification.Service, "New updates installed, lochnas will now restart.")
	}

	//Restart in background
	util.Command(false, Config.WorkingDirectory, nil, "service lochnas restart &")
	return "New updates installed, lochnas will now restart."
}

func (a AppsModel) params() string {
	var params []string
	for _, app := range a {
		if app.Enabled {
			params = append(params, "-f "+app.Path+"docker-compose.yml")
		}
	}
	return strings.Join(params, " ")
}

func (a AppsModel) NginxSites() error {
	enabled := false
	//Enable site apps if nginx is enabled
	for _, app := range a {
		if app.Name == "nginx" && app.Enabled {
			enabled = true
			break
		}
	}

	if enabled {
		for _, app := range a {
			tplPath := Config.WorkingDirectory + "/docker-templates/"
			copyPath := Config.WorkingDirectory + "/docker-data/nginx/templates/" + app.Name + ".apps.conf.template"

			if app.Enabled && app.Nginx {
				//Copy template to nginx folder, overwriting if it exists
				log.Printf("add template for %s\n", copyPath)
				err := util.CopyFile(tplPath+app.Name+"/nginx.conf", copyPath, true)
				if err != nil {
					log.Fatalln("Could not copy nginx.conf template for " + app.Name + ": " + err.Error())
				}

			} else if app.NginxLinked {
				//Remove the template
				log.Printf("remove template for %s\n", copyPath)
				if err := os.Remove(copyPath); err != nil {
					log.Fatalln(err)
				}
			}
		}
	}

	return nil
}

func (a AppsModel) Stop() string {
	params := a.params()
	if Config.Server.Debug {
		log.Println("docker-compose -f docker-compose.yml " + params + " stop")
	}

	util.Command(false, Config.WorkingDirectory, nil, "docker-compose -f docker-compose.yml "+params+" stop")
	return "App Stopped"
}

func (a AppsModel) PortCheck() {
	for _, app := range a {
		if app.Enabled {
			if ports, ok := app.ENV["PORT_CHECK"]; ok {
				ports := strings.Split(ports, ",") //Check for multiple ports
				for _, port := range ports {
					//Has port check flag, lets check it
					if Config.Server.Debug {
						log.Printf("Checking port %s for app %s\n", port, app.Name)
					}

					//Start server
					m := http.NewServeMux()
					s := http.Server{Addr: ":" + port, Handler: m}
					m.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
						// A very simple health check.
						w.WriteHeader(http.StatusOK)
						w.Header().Set("Content-Type", "application/json")
						io.WriteString(w, `ok`)
					})

					//Listen and server on go routine
					go func(s *http.Server) {
						if err := s.ListenAndServe(); err != nil && err != http.ErrServerClosed {
							log.Fatalln(err)
						}
					}(&s)

					//Give it a second to start up
					time.Sleep(100 * time.Millisecond)

					//Fetch body and check
					log.Println("Checking http://" + Config.Server.DDNS.IP + ":" + port)
					resp, err := http.Get("http://" + Config.Server.DDNS.IP + ":" + port)

					//free up http server port binding
					if err := s.Close(); err != nil {
						log.Fatalln(err)
					}

					//TODO: Probably let the user know instead of quiting out, telegram or notify package

					if err != nil {
						log.Fatalln("error connecting: " + err.Error())
					}

					defer resp.Body.Close()

					body, err := ioutil.ReadAll(resp.Body)

					if err != nil {
						log.Fatalln("error reading body: " + err.Error())
					}

					if string(body) != "ok" {
						log.Fatalln("message != ok")
					}
				}
			}
		}
	}
}

func (a AppsModel) AfterStart() {
	for _, app := range a {
		if app.Enabled && app.AfterStart {
			util.Command(false, Config.WorkingDirectory, nil, Config.WorkingDirectory+"/docker-templates/"+app.Name+"/after-start.sh")
		}
	}
}

func (a AppsModel) BeforeStart() {
	for _, app := range a {
		if app.Enabled && app.BeforeStart {
			util.Command(false, Config.WorkingDirectory, nil, Config.WorkingDirectory+"/docker-templates/"+app.Name+"/before-start.sh")
		}
	}
}

// Check to make sure app domains match the ip address
func (a AppsModel) DomainIPCheck() {
	for _, app := range a {
		if app.Enabled && app.ServerName != "" {
			if err := util.DomainIP(app.ServerName, Config.Server.DDNS.IP); err != nil {
				log.Println("Domain IP Check failed for " + app.ServerName + ": " + err.Error())

				if Config.Server.DDNS.Notification.Enabled {
					Config.Server.Notifications.Notify(Config.Server.DDNS.Notification.Service, "Domain IP Check failed for "+app.ServerName+": "+err.Error())
				}
			}
		}
	}
}

func (a AppsModel) Start() string {

	//Build docker params
	params := a.params()
	if Config.Server.Debug {
		log.Println(params)
	}

	//Stop if running
	a.Stop()

	//Before Start
	a.BeforeStart()

	//Enable nginx subdomains
	a.NginxSites()

	//IP Check/Update
	DDNS.Refresh()

	//SSL Check
	Domain.Check()

	//Check ports
	a.PortCheck()

	//domain ip check
	a.DomainIPCheck()

	//Check for container updates
	util.Command(false, Config.WorkingDirectory, nil, "docker-compose -f docker-compose.yml "+params+" pull")

	//Run
	util.Command(false, Config.WorkingDirectory, nil, "docker-compose -f docker-compose.yml "+params+" up -d --build --remove-orphans --force-recreate")

	//Remove old container data
	util.Command(false, Config.WorkingDirectory, nil, "docker image prune -f")
	util.Command(false, Config.WorkingDirectory, nil, "docker volume prune -f")
	util.Command(false, Config.WorkingDirectory, nil, "docker network prune -f")

	//After Start
	a.AfterStart()

	return "Start() Completed"
}
