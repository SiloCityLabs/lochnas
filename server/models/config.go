package models

import (
	"fmt"
	"os"
	"time"

	"gopkg.in/yaml.v2"
)

var DefaultConfigPath = "config.yml"
var Config ConfigModel

// Config struct for webapp config
type ConfigModel struct {
	// Path to where config.yml is stored
	Path             string `yaml:"-"`
	WorkingDirectory string `yaml:"-"`
	Server           struct {
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
			IP  string   `yaml:"ip"`
			URL []string `yaml:"url"`
		} `yaml:"ddns"`
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

	return nil
}

func (c *ConfigModel) Write() error {
	return nil
}
