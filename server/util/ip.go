package util

import (
	"errors"
	"log"

	dns "github.com/Focinfi/go-dns-resolver"
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

func DomainIP(domain string, ip string) error {

	// Set timeout and retry times
	dns.Config.SetTimeout(uint(5))
	dns.Config.RetryTimes = uint(4)

	entries, err := dns.Exchange(domain, "208.67.222.222:53", dns.TypeA)

	if err != nil {
		log.Printf("Could not get IPs: %v\n", err)
	}

	if len(entries) == 0 {
		return errors.New("No IPs found")
	}

	//TODO: This fails for CNAMES
	// if len(entries) > 1 {
	// 	//Before throwing error make sure the multiple entries is not a CNAME
	// 	count := 0
	// 	for _, entry := range entries {
	// 		log.Printf("Entry: %v\n", entry.Type)
	// 		if entry.Type != "CNAME" {
	// 			count++
	// 		}
	// 	}

	// 	if count > 1 {
	// 		return errors.New("Multiple IPs found. Docker nas is not a clusterable application yet ;)")
	// 	}
	// }

	// log.Println("Found Domain:", domain)
	// log.Println("Found IP:", entries[0])

	if entries[0].Content != ip {
		return errors.New("IP address does not match")
	}

	return nil
}
