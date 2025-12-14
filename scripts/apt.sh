#!/bin/bash

set -e 

repo_dir="/etc/apt/sources.list.d"
repos=("pve-enterprise" "ceph")

for repo in "${repos[@]}"; do
    find "$repo_dir" -maxdepth 1 -type f -name "*$repo*" | while IFS= read -r file_path; do
        file_name=$(basename "$file_path")
        
        if [[ -n "$file_path" && -f "$file_path" ]]; then
            new_path="${file_path}.disabled"
            mv -v "$file_path" "$new_path"
        fi
    done
done

apt-get update
apt-get upgrade -y
apt install -y open-vm-tools