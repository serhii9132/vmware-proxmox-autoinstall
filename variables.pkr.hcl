locals {
    output_directory = "artifacts/${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"

    iso_url = "https://enterprise.proxmox.com/iso"
    iso_source = "./.cache"

    answer_filename = "answer.toml"
    http_dir = "/http"
    unattended = {
      "/${local.answer_filename}" = templatefile("${local.http_dir}/answer.toml.pkrtpl.hcl", { var = var })
    }
}

variable "guest_os_type"{
    type = string
}

variable "iso_file" {
    type = string
}

variable "iso_checksum" {
    type = string
}

variable "ip" {
    type = string
    default = env("IP")
}

variable "mask" {
    type = string
    default = env("MASK")
}

variable "gateway" {
    type = string
    default = env("GATEWAY")
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