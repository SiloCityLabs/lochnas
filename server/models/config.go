package models

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"time"

	"gopkg.in/yaml.v3"
)

var DefaultConfigPath = "config.yml"
var Config ConfigModel

// Config struct for webapp config
type ConfigModel struct {
	// Path to where config.yml is stored
	Path             string `yaml:"-"`
	WorkingDirectory string `yaml:"-"`
	Server           struct {
		// ENV variables used globally for many containers
		GlobalENV []string `yaml:"global-env"`

		// Run server in debug mode
		Debug bool `yaml:"debug"`

		// Port is the local machine TCP Port to bind the HTTP Server to
		Port    string `yaml:"port"`
		Timeout struct {
			// Server is the general server timeout to use
			// for graceful shutdowns
			Server time.Duration `yaml:"server,omitempty"`

			// Write is the amount of time to wait until an HTTP server
			// write opperation is cancelled
			Write time.Duration `yaml:"write,omitempty"`

			// Read is the amount of time to wait until an HTTP server
			// read operation is cancelled
			Read time.Duration `yaml:"read,omitempty"`

			// Read is the amount of time to wait
			// until an IDLE HTTP session is closed
			Idle time.Duration `yaml:"idle,omitempty"`
		} `yaml:"timeout,omitempty"`

		DDNS struct {
			IP           string              `yaml:"ip"`
			URL          []string            `yaml:"url"`
			Notification NotificationSetting `yaml:"notification"`
		} `yaml:"ddns"`

		Notifications NotificationsModel `yaml:"notifications"`
	} `yaml:"server"`
}

func (c *ConfigModel) Load() error {
	s, err := os.Stat(c.Path)
	if err != nil {
		return err
	}
	if s.IsDir() {
		return fmt.Errorf("'%s' is a directory, not a normal file", c.Path)
	}

	// Open config file
	file, err := os.Open(c.Path)
	if err != nil {
		return err
	}
	defer file.Close()

	// Init new YAML decode
	d := yaml.NewDecoder(file)

	// Start YAML decoding from file
	if err := d.Decode(&c); err != nil {
		return err
	}

	// Load global env in
	for _, env := range Config.Server.GlobalENV {
		envSplit := strings.SplitN(env, "=", 2)
		os.Setenv(envSplit[0], envSplit[1])
		if Config.Server.Debug {
			log.Println("Loading env: " + env)
		}
	}

	// Configure notifications
	if err := Config.Server.Notifications.Configure(); err != nil {
		return err
	}

	return nil
}

//Encode yaml and write to file
func (c *ConfigModel) Write() error {
	s, err := os.Stat(c.Path)
	if err != nil {
		return fmt.Errorf("os.Stat(%s) error: %s\n", c.Path, err.Error())
	}
	if s.IsDir() {
		return fmt.Errorf("'%s' is a directory, not a normal file", c.Path)
	}

	// Open config file
	file, err := os.Open(c.Path)
	if err != nil {
		return fmt.Errorf("os.Open error: %s\n", err.Error())
	}
	defer file.Close()

	yamlData, err := yaml.Marshal(&c)
	if err != nil {
		return fmt.Errorf("Error while Marshaling: %s\n", err.Error())
	}

	err = ioutil.WriteFile(c.Path, yamlData, 0644)
	if err != nil {
		return fmt.Errorf("Unable to write data into the file: %s\n", err.Error())
	}

	return nil
}
