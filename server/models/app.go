package models

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"server/util"
	"strings"

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

	//TODO: Root check

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
	util.Command(false, Config.WorkingDirectory, nil, "./scripts/update.sh")

	//TODO: Move update.sh stuff into this file. Prefferably not in the form of util.Command's
	// util.Command(false, Config.WorkingDirectory, nil, "apt update && apt dist-upgrade")
	// util.Command(false, Config.WorkingDirectory, nil, "git pull")

	//TODO: This will kill itself. May need to do it gracefully another way
	// util.Command(false, Config.WorkingDirectory, nil, "service docker-nas restart")
	return ""
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
			if app.Enabled && app.Nginx {
				if !app.NginxLinked {
					//Add a link
					new := dataPath + "nginx/sites/" + app.Name + ".apps.conf.template"
					err := os.Symlink("file.txt", "file-symlink.txt")
					if err != nil {
						fmt.Println(err)
						os.Exit(1)
					}
				}
			} else if app.NginxLinked {
				//Remove the link
			}
		}
	}

	return nil
}

func (a AppsModel) Stop() string {
	//TODO: Stop if running
	//docker-compose $DOCKER_FILES stop
	return ""
}

func (a AppsModel) Start() string {

	//Build docker params
	params := a.params()
	log.Println(params)

	//Enable nginx subdomains

	//Stop if running
	a.Stop()

	//TODO: Check ports
	//source scripts/port-check.sh
	// 80,443,32400,25565
	// web,ssl,plex,minecraft

	//TODO: Check for updates
	//docker-compose $DOCKER_FILES pull

	//TODO: Run
	//docker-compose $DOCKER_FILES up -d --build --remove-orphans --force-recreate

	//TODO: Remove old images
	//docker image prune -f
	//docker volume prune -f

	//TODO: After Start
	//source scripts/after-start.sh

	return "Start() Completed"
}
