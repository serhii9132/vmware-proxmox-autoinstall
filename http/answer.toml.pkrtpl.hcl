[global]
country = "ua"
fqdn = "pve.home.arpa"
keyboard = "en-us"
mailto = "root@pve"
timezone = "Europe/Kyiv"
reboot-mode = "reboot"
root-password-hashed = "${var.ssh_password}"
root-ssh-keys = [
    "${var.ssh_pub_key}"
]

[network]
source = "from-dhcp"

[disk-setup]
filesystem = "ext4"
disk-list = ["sda"]
lvm.swapsize = 0
lvm.maxroot = 25
lvm.maxvz = 0