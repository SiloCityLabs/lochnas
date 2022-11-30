package models

import (
	"io/ioutil"
	"server/util"
)

var Daemon DaemonModel

// DaemonModel ...
type DaemonModel map[string]string

func (a DaemonModel) Init() {

}

func (a DaemonModel) Install() string {
	//Copy all .env.example to .env
	templates, err := ioutil.ReadDir("/lochnas/docker-templates/")
	if err != nil {
		return "Unable to read /lochnas/docker-templates: " + err.Error()
	}

	for _, appFolder := range templates {
		if appFolder.IsDir() {
			appPath := "/lochnas/docker-templates/" + appFolder.Name()

			if !util.FileExists(appPath+"/.env") && util.FileExists(appPath+"/.env.example") {
				util.CopyFile(appPath+"/.env.example", appPath+"/.env", false)
			}
		}
	}

	return "Configuration files created"
}

func (a DaemonModel) Uninstall() string {
	return ""
}
