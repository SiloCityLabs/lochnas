package util

import (
	"os"
	"os/exec"
)

func Command(output bool, wd string, envList []string, command string) (string, error) {

	// log.Println("Running command " + command + " " + strings.Join(arg, " "))

	//Running withouth bash -c causes golang to hold on to port bindings and fails docker restart
	cmd := exec.Command("bash", "-c", command)
	cmd.Dir = wd
	cmd.Env = os.Environ()
	if envList != nil {
		cmd.Env = append(cmd.Env, envList...)
	}

	// fmt.Println(cmd.Env)

	if output {
		out, err := cmd.CombinedOutput()
		return string(out), err
	} else {
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		err := cmd.Start()
		if err != nil {
			return "", err
		}
		err = cmd.Wait()
		if err != nil {
			return "", err
		}
		err = cmd.Process.Release()
		if err != nil {
			return "", err
		}
	}

	return "", nil
}
