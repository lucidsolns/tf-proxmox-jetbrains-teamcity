# Terraform to deploy Jetbrains Teamcity on a Flatcar Container Linux VM running on Proxmox

This repository contains:
  - a Terraform script
  - that provisions a [Teamcity build server](https://hub.docker.com/r/jetbrains/teamcity-server/)
  - on a Proxmox virtualisation environment (QEMU/KVM) using bpg/proxmox
  - and a [custom module](https://registry.terraform.io/modules/lucidsolns/flatcar-vm/proxmox/latest)
  - with a [Flatcar Container Linux](https://www.flatcar.org/) VM
  - with a Postgres database [container](https://hub.docker.com/_/postgres)
  - using a simple [docker compose](config/docker-compose.yaml)
  - with a [butane/ignition](jetbrains-teamcity.bu.tftpl) script


# Residuals

- add a healthcheck to the containers
- change the filesystem permission setup (was runtime script in the service start, but changing to virtiofs
  should mean this can be simplified)


# Links

- https://www.jetbrains.com/teamcity/
