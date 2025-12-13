#!/bin/bash

apt autoremove -y
apt clean
dd if=/dev/zero of=/zerofile bs=1M status=progress
rm /zerofile