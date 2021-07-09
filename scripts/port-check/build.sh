#!/bin/bash

env GOOS=linux GOARCH=386 go build -o port-check.i386.bin port-check.go
env GOOS=linux GOARCH=amd64 go build -o port-check.amd64.bin port-check.go
env GOOS=linux GOARCH=arm go build -o port-check.armhf.bin port-check.go
env GOOS=linux GOARCH=arm64 go build -o port-check.arm64.bin port-check.go
chmod +x port-check.*.bin