# Terraform to deploy Jetbrains Teamcity on a Flatcar Container Linux VM running on Proxmox

This [repository](https://github.com/lucidsolns/tf-proxmox-jetbrains-teamcity) contains:
  - a Terraform script
  - that provisions a [Teamcity build server](https://hub.docker.com/r/jetbrains/teamcity-server/)
  - on a Proxmox virtualisation environment (QEMU/KVM) using bpg/proxmox
  - and a [custom module](https://registry.terraform.io/modules/lucidsolns/flatcar-vm/proxmox/latest)
  - with a [Flatcar Container Linux](https://www.flatcar.org/) VM
  - with a Postgres database [container](https://hub.docker.com/_/postgres)
  - using a simple [docker compose](config/docker-compose.yaml)
  - with a [butane/ignition](jetbrains-teamcity.bu.tftpl) script
  - using a sysext for [docker compose](https://flatcar.github.io/sysext-bakery/docker_compose/) in Flatcar 

# Hub integration

The Teamcity Hub [integration](https://plugins.jetbrains.com/plugin/9156-jetbrains-hub-integration) is worse 
than it was 10 years ago.

Steps to make it work:
-  Unban "guest" on Hub
-  Grant the role "System Admin" to "guest" user (temporarily)  [**Massive red flag**]
-  Register Hub on Teamcity (Menu Administration -> Hub Settings)
-  Add "/hub" to server url, e.g: "https : //my-hub.domain/hub"
-  Click Register Server
-  Remove "System Admin" role from "guest" user and ban it.


# Residuals

- convert the docker compose to podman with quadlet configurations
- add a health check to the containers
- change the filesystem permission setup (was runtime script in the service start, but changing to virtiofs
  should mean this can be simplified)


# Links

- https://www.jetbrains.com/teamcity/
- https://plugins.jetbrains.com/plugin/9156-jetbrains-hub-integration
