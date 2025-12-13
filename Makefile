ENV_FILE := .env
LOAD_ENV := set -a; [ -f $(ENV_FILE) ] && . ./$(ENV_FILE); set +a
BUILDS_DIR := builds

proxmox:
	@packer init proxmox.pkr.hcl
	@$(LOAD_ENV) && packer build proxmox.pkr.hcl

clean: $(BUILDS_DIR)
	rm -rf $(BUILDS_DIR) packer_cache