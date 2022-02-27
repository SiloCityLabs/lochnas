package util

import (
	"errors"

	"gitlab.com/NebulousLabs/go-upnp"
)

func IP() (string, error) {
	// connect to router
	d, dErr := upnp.Discover()
	if dErr != nil {
		return "", errors.New("Error discovering router: " + dErr.Error())
	}

	// discover external IP
	ip, ipErr := d.ExternalIP()
	if ipErr != nil {
		return "", errors.New("Error fetching external IP address: " + ipErr.Error())
	}

	return ip, nil
}
