package nas

func Start(rootPath string) error {
	//Load env

	if err := dockerInstalled(); err != nil {
		return err
	}

	if err := dockerComposeInstalled(); err != nil {
		return err
	}

	//Build docker params

	//Stop if running

	//Check ports

	//Check for updates

	//Run

	//Remove old images

	//After Start

	return nil
}
