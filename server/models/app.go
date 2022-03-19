package models

import (
	"context"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"server/util"
	"strings"
	"sync"
	"time"

	"github.com/joho/godotenv"
)

var Apps AppsModel

type AppsModel []AppModel

//AppModel ...
type AppModel struct {
	// Folder name of the app
	Name string
	// App path
	Path string
	// Is the app enabled
	Enabled bool
	// Has after-start.sh file
	AfterStart bool
	// Has nginx.conf file
	Nginx       bool
	NginxLinked bool
	// ENV Variables
	ENV map[string]string
}

func (a AppsModel) New() (AppsModel, error) {
	tplPath := Config.WorkingDirectory + "/docker-templates/"
	dataPath := Config.WorkingDirectory + "/docker-data/"

	//TODO: Root check, This might need to go in main() instead

	if err := a.DockerInstalled(); err != nil {
		return a, err
	}

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
				}
			}

			//Check nginx.conf
			if _, err := os.Stat(app.Path + "nginx.conf"); err == nil {
				app.Nginx = true
			}

			//Check if nginx.conf is already symlinked
			nginxPath := dataPath + "nginx/sites/" + app.Name + ".apps.conf.template"
			if f, err := os.Lstat(nginxPath); err == nil {
				if f.Mode()&os.ModeSymlink == os.ModeSymlink {
					originFile, err := os.Readlink(nginxPath)
					if err == nil && originFile == app.Path+"nginx.conf" {
						app.NginxLinked = true
					}
				}
			}

			//Check after-start.sh
			if _, err := os.Stat(app.Path + "after-start.sh"); err == nil {
				app.AfterStart = true
			}

			a = append(a, app)
		} else {
			//TODO: Link user to folder structure github docs link
		}
	}

	return a, nil
}

func (a AppsModel) DockerInstalled() error {

	// # Install docker
	out, err := util.Command(true, "/", nil, "command -v docker")
	if err != nil || out == "" {
		return errors.New("docker not detected due to error (" + err.Error() + ")")
	}
	// # Install docker-compose
	out, err = util.Command(true, "/", nil, "command -v docker-compose")
	if err != nil || out == "" {
		return errors.New("docker not detected due to error (" + err.Error() + ")")
	}

	//TODO: Ask the user if they want to install docker
	// if ! [ -x "$(command -v docker)" ]; then
	// 	curl -fsSL https://get.docker.com -o get-docker.sh
	// 	sh get-docker.sh
	// fi

	//TODO: Ask the user if they want to install docker-compose
	// # Install docker-compose
	// if ! [ -x "$(command -v docker-compose)" ]; then
	// 	apt install -y docker-compose
	// fi

	if Config.Server.Debug {
		log.Println("Docker detected in path " + out)
	}

	return nil
}

func (a AppsModel) Test() string {

	return ""
}

func (a AppsModel) Update() string {
	// util.Command(false, Config.WorkingDirectory, nil, "./scripts/update.sh")

	//TODO: Move update.sh stuff into this file. Prefferably not in the form of util.Command's
	// util.Command(false, Config.WorkingDirectory, nil, "apt update && apt dist-upgrade")
	// util.Command(false, Config.WorkingDirectory, nil, "git pull")

	//TODO: This will kill itself. May need to do it gracefully another way
	// util.Command(false, Config.WorkingDirectory, nil, "service docker-nas restart")
	return "NOT WORKING YET"
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
			linkPath := Config.WorkingDirectory + "/docker-data/nginx/sites/" + app.Name + ".apps.conf.template"

			if app.Enabled && app.Nginx {
				if !app.NginxLinked {
					//Add a link
					log.Printf("add link for %s\n", linkPath)
					if err := os.Symlink(tplPath+app.Name+"/nginx.conf", linkPath); err != nil {
						log.Fatalln(err)
					}
				} else if Config.Server.Debug {
					log.Printf("Symlink already exists for %s skipping...\n", linkPath)
				}
			} else if app.NginxLinked {
				//Remove the link
				log.Printf("remove link for %s\n", linkPath)
				if err := os.Remove(linkPath); err != nil {
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
		log.Println(params)
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
					blockit := sync.WaitGroup{}
					blockit.Add(1)
					go func(port string, blockit *sync.WaitGroup) {
						m := http.NewServeMux()
						s := http.Server{Addr: ":" + port, Handler: m}
						m.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
							// A very simple health check.
							w.WriteHeader(http.StatusOK)
							w.Header().Set("Content-Type", "application/json")
							io.WriteString(w, `ok`)
						})
						if err := s.ListenAndServe(); err != nil && err != http.ErrServerClosed {
							log.Fatalln(err)
						}

						blockit.Wait()

						s.Shutdown(context.Background())
					}(port, &blockit)

					//Give it a second to start up
					time.Sleep(1 * time.Second)

					//Fetch body and check
					fmt.Println("Checking http://" + Config.Server.DDNS.IP + ":" + port)
					resp, err := http.Get("http://" + Config.Server.DDNS.IP + ":" + port)
					blockit.Done()

					//TODO: Probably let the user know instead of quiting out, telegram or notify package
					//TODO: timeout 3 seconds

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

func (a AppsModel) Start() string {

	//Build docker params
	params := a.params()
	if Config.Server.Debug {
		log.Println(params)
	}

	//Enable nginx subdomains
	a.NginxSites()

	//Stop if running
	a.Stop()

	//Check ports
	a.PortCheck()

	//Check Domains
	//a.DomainCheck() //TODO: Similar to port check but for domain->ip match

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
