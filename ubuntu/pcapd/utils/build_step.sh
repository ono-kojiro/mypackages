#!/bin/sh

remote="192.168.1.52"

mkdir -p /home/agent/pcapd
rsync -avz --remove-source-files $remote:/home/pcapd/pcapd/* \
  /home/agent/pcapd/

