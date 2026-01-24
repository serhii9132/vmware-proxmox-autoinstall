#!/bin/bash

dd if=/dev/zero of=/zerofile bs=1M status=progress
rm /zerofile