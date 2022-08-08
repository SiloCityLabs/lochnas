package models

import (
	"context"
	"fmt"
	"strings"

	"github.com/nikoksr/notify"
	"github.com/nikoksr/notify/service/mail"
	"github.com/nikoksr/notify/service/telegram"
)

type NotificationsModel struct {
	Enabled  bool   `yaml:"enabled"`
	Subject  string `yaml:"subject,omitempty"`
	Services struct {
		Telegram struct {
			Enabled   bool               `yaml:"enabled"`
			Token     string             `yaml:"token"`     //Telegram bot token
			Receivers []int64            `yaml:"receivers"` //Telegram chat_id (https://stackoverflow.com/questions/32423837/telegram-bot-how-to-get-a-group-chat-id)
			Service   *telegram.Telegram `yaml:"-"`
		} `yaml:"telegram"`
		Email struct {
			Enabled   bool       `yaml:"enabled"`
			Server    string     `yaml:"server"`    //SMTP server address
			From      string     `yaml:"from"`      //Email from address
			Username  string     `yaml:"username"`  //SMTP username
			Password  string     `yaml:"password"`  //SMTP password
			Receivers []string   `yaml:"receivers"` //Email receivers (to addresses)
			Service   *mail.Mail `yaml:"-"`
		} `yaml:"email"`
	} `yaml:"services"`
}

//Struct used for individual feature notifications
type NotificationSetting struct {
	Enabled bool   `yaml:"enabled"`
	Service string `yaml:"service"`
}

func (a NotificationsModel) Configure() error {
	if !Config.Server.Notifications.Enabled {
		return nil
	}

	//Enable telegram notifications
	if Config.Server.Notifications.Services.Telegram.Enabled {
		telegramService, err := telegram.New(Config.Server.Notifications.Services.Telegram.Token)
		if err != nil {
			return err
		}
		telegramService.AddReceivers(Config.Server.Notifications.Services.Telegram.Receivers...)
		Config.Server.Notifications.Services.Telegram.Service = telegramService
		notify.UseServices(telegramService)
	}

	//Enable email(mail) notifications
	if Config.Server.Notifications.Services.Email.Enabled {
		mailService := mail.New(Config.Server.Notifications.Services.Email.From, Config.Server.Notifications.Services.Email.Server)
		mailService.AuthenticateSMTP("", Config.Server.Notifications.Services.Email.Username, Config.Server.Notifications.Services.Email.Password, Config.Server.Notifications.Services.Email.Server)
		mailService.AddReceivers(Config.Server.Notifications.Services.Email.Receivers...)
		Config.Server.Notifications.Services.Email.Service = mailService
		notify.UseServices(mailService)
	}

	return nil
}

//With Settings struct Notify the user with message
func (a NotificationsModel) notifyAll(message string) {
	// Send a test message.
	_ = notify.Send(
		context.Background(),
		a.Subject,
		message,
	)
}

func (a NotificationsModel) Notify(service string, message string) {
	if !a.Enabled {
		return
	}

	if service == "" {
		a.notifyAll(message)
		return
	}

	ctx := context.Background()
	// Send a test message.
	switch strings.ToLower(service) {
	case "telegram":
		if Config.Server.Notifications.Services.Telegram.Enabled {
			Config.Server.Notifications.Services.Telegram.Service.Send(ctx, a.Subject, message)
		}
	case "email":
		if Config.Server.Notifications.Services.Email.Enabled {
			Config.Server.Notifications.Services.Email.Service.Send(ctx, a.Subject, message)
		}
	default:
		fmt.Println("Service '" + service + "' not found")
	}
}

func (a NotificationsModel) Test() string {
	a.Notify("", "Test")
	return "Test complete!"
}
