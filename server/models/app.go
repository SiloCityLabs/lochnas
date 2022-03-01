package models

import "server/util"

var App AppModel

//AppModel ...
type AppModel map[string]string

func (a AppModel) Init() {
	// a["ip"] = env.Get("GLOBAL_DDNS_IP")
}

func (a AppModel) Test() string {

	return ""
}

func (a AppModel) Update() string {
	util.Command(false, Config.WorkingDirectory, nil, "./scripts/update.sh")
	// util.Command(false, Config.WorkingDirectory, nil, "apt update && apt dist-upgrade")
	// util.Command(false, Config.WorkingDirectory, nil, "git pull")
	// util.Command(false, Config.WorkingDirectory, nil, "service docker-nas restart")
	return ""
}
