package nas

import (
	"errors"
	"log"
	"server/util"
)

func dockerInstalled() error {

	// # Install docker
	out, err := util.Command(true, "/", nil, "command -v docker")
	if err != nil {
		return err
	}
	if out == "" {
		return errors.New("docker not detected")
	}

	// if ! [ -x "$(command -v docker)" ]; then
	// 	curl -fsSL https://get.docker.com -o get-docker.sh
	// 	sh get-docker.sh
	// fi

	log.Println(out)

	return errors.New("test")
	// return nil
}

func dockerComposeInstalled() error {

	// # Install docker-compose
	// if ! [ -x "$(command -v docker-compose)" ]; then
	// 	apt install -y docker-compose
	// fi
	return nil
}
