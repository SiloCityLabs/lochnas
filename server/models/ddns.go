package models

import (
	"errors"
	"fmt"
	"log"
	"net/http"

	"server/util"
)

var DDNS DDNSModel

//AppModel ...
type DDNSModel map[string]string

func (a DDNSModel) Init() {
	// a["ip"] = env.Get("GLOBAL_DDNS_IP")
}

func (a DDNSModel) Refresh() string {
	ip, err := util.IP()
	if err != nil {
		return err.Error()
	}

	if Config.Server.DDNS.IP != ip {
		log.Printf("IP Changed (%s != %s), running ddns update", ip, Config.Server.DDNS.IP)
		Config.Server.DDNS.IP = ip

		if err := Config.Write(); err != nil {
			log.Fatal("Cannot write config: ", err)
		}

		for _, url := range Config.Server.DDNS.URL {
			if err := a.URL(url); err != nil {
				return err.Error()
			}
		}
	}

	return ip
}

func (a DDNSModel) Force() string {
	ip, err := util.IP()
	if err != nil {
		return err.Error()
	}

	log.Printf("Running ddns update %s %s\n", ip, Config.Server.DDNS.IP)
	Config.Server.DDNS.IP = ip

	if err := Config.Write(); err != nil {
		log.Fatal("Cannot write config: ", err)
	}

	for _, url := range Config.Server.DDNS.URL {
		if err := a.URL(url); err != nil {
			return err.Error()
		}
	}

	return ip
}

func (a DDNSModel) WanIp() string {
	ip, err := util.IP()
	if err != nil {
		return err.Error()
	}

	return ip
}

func (a DDNSModel) URL(url string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}

	fmt.Println("HTTP Response Status:", resp.StatusCode, http.StatusText(resp.StatusCode))

	if resp.StatusCode >= 200 && resp.StatusCode <= 299 {
		fmt.Println("Updated URL DDNS")
	} else {
		return errors.New("something went wrong while trying to hit url ddns update")
	}

	return nil
}
