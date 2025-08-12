terraform {
  required_version = "> 1.12.0"

  required_providers {
    /**

      see:
        - https://registry.terraform.io/providers/bpg/proxmox/latest/docs
     */
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.81.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}

/**
   Configure the provider with SSH agent support, and hack in a username.

   TODO: Create a terraform user, and use an API token
 */
provider "proxmox" {

  endpoint = var.pm_api_url
  username = var.pm_user
  password = var.pm_password
  insecure = true
  ssh {
    agent    = true
    username = var.ssh_username
  }
}
