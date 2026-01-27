packer {
  required_plugins {
    vmware = {
      source = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "vmware-iso" "proxmox" {
  version                        = 21
  firmware                       = "bios"
  headless                       = true
  skip_export                    = true
  guest_os_type                  = var.guest_os_type
  vm_name                        = "proxmox-auto"
  vhv_enabled                    = true

  cpus                           = 4
  cores                          = 4
  memory                         = 8192
  disk_size                      = 200000
  disk_type_id                   = 0
  disk_adapter_type              = "scsi"
  network_adapter_type           = "vmxnet3"

  cdrom_adapter_type             = "sata"
  iso_url                        = "${local.iso_url}/${var.iso_file}"
  iso_checksum                   = "sha256:${var.iso_checksum}"
  iso_target_path                = abspath("${local.iso_source}/${var.iso_file}")
  output_directory               = abspath("${local.output_directory}")

  communicator                   = "ssh"

  http_content                   = local.unattended                  

  vnc_bind_address               = "127.0.0.1"
  vnc_port_min                   = 5963
  vnc_port_max                   = 5963
  vnc_disable_password           = true
  
  ssh_host                       = var.ip
  ssh_username                   = "root"
  ssh_private_key_file           = var.ssh_private_key_file
  ssh_timeout                    = "30m"

  boot_wait                      = "10s"
  boot_command = [
    "<down><down><enter>",
    "<down><down><down><enter>",
    "<wait30s>",
    "proxmox-fetch-answer http http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.answer_filename} > /run/automatic-installer-answers<enter><wait>exit<enter>",
    "<wait3m>"
  ]
  shutdown_command               = "poweroff"
}

build {
  sources = ["sources.vmware-iso.proxmox"]

  provisioner "shell" {
    scripts = [
      "./provisioning/shell/extend-lvm.sh",
      "./provisioning/shell/disable-apt-repos.sh",
      "./provisioning/shell/install-packages.sh"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "./provisioning/ansible/playbook.yaml"
    inventory_file  = "./provisioning/ansible/hosts.yaml"
    host_vars       = "./provisioning/ansible/host_vars"
    role_paths      = [ "./provisioning/ansible/roles/users" ]
    galaxy_file     = "./provisioning/ansible/requirements.yaml"
    extra_arguments = [ "-vvvv" ]
  }

  provisioner "shell" {
    script = "./provisioning/shell/zero-space.sh"
  }

  post-processor "vagrant" {
    compression_level    = 6
    keep_input_artifact  = true
    output               = "${local.output_directory}/proxmox.box"
  }
}