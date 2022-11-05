package models

import (
	"bufio"
	"bytes"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"
)

var Disks DisksModel

// DisksModel ...
type DisksModel []string

func (d DisksModel) Init() (DisksModel, error) {
	var drives []string
	driveMap := make(map[string]bool)
	dfPattern := regexp.MustCompile(`^(\\/[^ ]+)[^%]+%[ ]+(.+)$`)

	out, err := exec.Command("df", "-x", "overlay", "-x", "tmpfs").Output()

	log.Println(string(out))

	if err != nil {
		log.Printf("Error calling df: %s", err)
	}

	s := bufio.NewScanner(bytes.NewReader(out))
	for s.Scan() {
		line := s.Text()
		if dfPattern.MatchString(line) {
			device := dfPattern.FindStringSubmatch(line)[1]
			rootPath := dfPattern.FindStringSubmatch(line)[2]

			log.Println(device + ": " + rootPath)

			// if ok := isUSBStorage(device); ok {
			driveMap[rootPath] = true
			// }
		}
	}

	log.Println(driveMap)

	for k := range driveMap {
		file, err := os.Open(k)
		if err == nil {
			drives = append(drives, k)
		}
		file.Close()
	}

	d = drives

	return d, nil
}

func (d DisksModel) List() string {
	log.Println(d)

	return "Done!"
}

func isUSBStorage(device string) bool {
	deviceVerifier := "ID_USB_DRIVER=usb-storage"
	cmd := "udevadm"
	args := []string{"info", "-q", "property", "-n", device}
	out, err := exec.Command(cmd, args...).Output()

	if err != nil {
		log.Printf("Error checking device %s: %s", device, err)
		return false
	}

	if strings.Contains(string(out), deviceVerifier) {
		return true
	}

	return false
}
