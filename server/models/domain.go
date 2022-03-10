package models

import (
	"os"
	"server/util"
)

var Domain DomainModel

//DomainModel ...
type DomainModel map[string]string

func (a DomainModel) Init() {
	// a["ip"] = env.Get("GLOBAL_DDNS_IP")
}

//TODO: Bring domain-renew the fully into golang
func (a DomainModel) Renew() string {
	util.Command(false, Config.WorkingDirectory, nil, "./scripts/domain-renew.sh")
	util.Command(false, Config.WorkingDirectory, nil, "docker restart nginx")
	return ""
}

//TODO: Bring domain-add the fully into golang
func (a DomainModel) Add() string {
	args := os.Args[1:]

	if len(args) != 1 {
		return "Please supply only one domain name like: './server.bin -domain add domain.com'"
	}

	util.Command(false, Config.WorkingDirectory, nil, "./scripts/domain-add.sh "+args[0])
	return ""
}

//TODO: Bring domain-remove the fully into golang
func (a DomainModel) Delete() string {
	util.Command(false, Config.WorkingDirectory, nil, "./scripts/domain-remove.sh")
	return ""
}
