#!/bin/bash

set -e

lvextend -l +100%FREE /dev/pve/root
resize2fs /dev/pve/root