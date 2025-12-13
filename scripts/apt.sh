#!/bin/bash

set -e 

mv -v /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.disabled
mv -v /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.disabled

apt-get update
apt-get upgrade -y
apt install -y open-vm-tools