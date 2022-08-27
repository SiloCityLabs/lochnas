package util

import (
	"bufio"
	"errors"
	"fmt"
	"log"
	"os"
	"strings"
)

func Confirm(msg string) bool {
	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Printf("%s [y/n]: ", msg)

		input, err := reader.ReadString('\n')
		if err != nil {
			log.Fatal(err)
		}

		input = strings.TrimSpace(strings.ToLower(input))

		if input == "y" || input == "yes" {
			return true
		} else if input == "n" || input == "no" {
			return false
		}
	}
}

func DockerInstalled() error {

	// Check for docker
	out, err := Command(true, "/", nil, "command -v docker")
	if err != nil {
		return errors.New("docker not detected due to error (" + err.Error() + ")")
	}
	// Check for docker-compose
	out, err = Command(true, "/", nil, "command -v docker-compose")
	if err != nil {
		return errors.New("docker not detected due to error (" + err.Error() + ")")
	}

	// Ask the user if they want to install docker
	if out == "" {
		if !Confirm("docker not detected, would you like to install it?") {
			return errors.New("Please manually install docker")
		} else {
			//Install docker
			if _, err := Command(false, "/", nil, "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"); err != nil {
				return errors.New("Error installing docker: " + err.Error())
			}
		}
	}

	// Ask the user if they want to install docker-compose
	if out == "" {
		if !Confirm("docker-compose not detected, would you like to install it?") {
			return errors.New("Please manually install docker-compose")
		} else {
			//Install docker-compose
			if _, err := Command(false, "/", nil, "apt install -y docker-compose"); err != nil {
				return errors.New("Error installing docker-compose: " + err.Error())
			}
		}
	}

	return nil
}
