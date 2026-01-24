ENV_FILE := .env
LOAD_ENV := set -a; [ -f $(ENV_FILE) ] && . ./$(ENV_FILE); set +a
BUILDS_DIR := builds

proxmox-8:
	@packer init proxmox.pkr.hcl
	@$(LOAD_ENV) && \
	packer build \
	-var 'iso_file=proxmox-ve_8.4-1.iso' \
	-var 'iso_checksum=d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8' \
	-var 'guest_os_type=debian12-64' .
	
proxmox-9:
	@packer init proxmox.pkr.hcl
	@$(LOAD_ENV) && \
	packer build \
	-var 'iso_file=proxmox-ve_9.1-1.iso' \
	-var 'iso_checksum=6d8f5afc78c0c66812d7272cde7c8b98be7eb54401ceb045400db05eb5ae6d22' \
	-var 'guest_os_type=debian13-64' .

clean: $(BUILDS_DIR)
	@rm -rf $(BUILDS_DIR) packer_cache