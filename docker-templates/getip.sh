#!/bin/bash

wanip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
hostname="$(hostname)"