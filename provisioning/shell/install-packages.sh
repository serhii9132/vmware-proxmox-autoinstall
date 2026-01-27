#!/bin/bash

set -e 

apt-get update
apt-get upgrade -y
apt install -y open-vm-tools ansible python3.13-venv python3-pip