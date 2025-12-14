packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

locals {
    output_directory = "builds/${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"

    iso_url = "https://enterprise.proxmox.com/iso"
    iso_source = "./iso"

    answer_filename = "answer.toml"
    http_dir = "/http"
    unattended = {
      "/${local.answer_filename}" = templatefile("${local.http_dir}/answer.toml.pkrtpl.hcl", { var = var })
    }
}

variable "iso_file" {
    type = string
    default = env("ISO_FILE_PROXMOX")
}

variable "iso_checksum" {
    type = string
    default = env("CHECKSUM_ISO_FILE_PROXMOX")
}

variable "ssh_password" {
    type = string
    default = env("PASSWORD")
}

variable "ssh_pub_key" {
    type = string
    default = env("PUBLIC_KEY")
}

variable "ssh_private_key_file" {
    type = string
    default = env("PRIVATE_KEY_FILE")
}

source "vmware-iso" "proxmox" {
  version                        = 21
  firmware                       = "bios"
  headless                       = true
  vmx_remove_ethernet_interfaces = true
  skip_export                    = true
  guest_os_type                  = "debian12-64"
  vm_name                        = "proxmox-auto"

  cpus                           = 4
  cores                          = 4
  memory                         = 8192
  disk_size                      = 200000
  disk_type_id                   = 0
  disk_adapter_type              = "scsi"

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

  vmx_data = {
    "ethernet0.virtualdev" = "vmxnet3"
  }
}

build {
  sources = ["sources.vmware-iso.proxmox"]

  provisioner "shell" {
    scripts = [
      "./scripts/storage.sh",
      "./scripts/apt.sh",
      "./scripts/zero-space.sh"
    ]
  }

  post-processor "vagrant" {
    compression_level    = 6
    keep_input_artifact  = true
    output               = "${local.output_directory}/proxmox.box"
  }
}