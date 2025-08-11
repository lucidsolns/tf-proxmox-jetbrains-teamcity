terraform {
  required_version = ">= 1.12.0"
}
/*
    Jetbrains Teamcity (deployed as a container on Flatcar Linux)

    Before creating the VM, the following ZFS based directory is used for Teamcity data:
      zfs create -o quota=10G -o mountpoint=/droplet/data/jetbrains-teamcity-data droplet/141-olive-jetbrains-teamcity-data
    The data directory is put into the Flatcar Linux VM using virtiofs, then it
    is mounted using 2 paths into the hub docker container.

*/
module "olive" {
  # source = "../terraform-proxmox-flatcar-vm"
  source  = "lucidsolns/flatcar-vm/proxmox"
  version = "1.0.6"

  node_name      = var.target_node
  vm_id          = 141
  vm_name        = "olive.lucidsolutions.co.nz"
  vm_description = <<-EOT
      Jetbrains Teamcity running as a container on Flatcar Linux with virtiofs for data/logs/conf/backup
  EOT
  tags = ["flatcar", "jetbrains", "teamcity", "development"]

  butane_conf         = "${path.module}/jetbrains-teamcity.bu.tftpl"
  butane_snippet_path = "${path.module}/config"

  memory = {
    dedicated = 4096
  }

  bridge  = var.bridge
  vlan_id = 120

  storage_images = var.storage_images
  storage_root   = var.storage_root
  storage_path_mapping = var.storage_path_mapping

  // Note: move back to stable once the virtiofs is in stable
  flatcar_channel = "beta"
  flatcar_version = "4344.1.1"

  //  The 'Data Center' direction mappings must be created manually before
  //  running this script. Create a mapping:
  //      - with the mapping name 'teamcity-data'
  //      - with a directory '/droplet/data/jetbrains-teamcity-data' or where ever there is disk
  //
  directories = [
    {
      name = "teamcity-data"
    }
  ]

  disks = [
    // A non-persistent sparse disk for swap, this is /dev/vda in the VM
    {
      datastore_id = var.storage_data # hack, this must be 'present'
      size = "4" # hack, this must be present
      iothread = true
      discard = "on" # enable 'trim' support, as ZFS supports this
      backup   = false
    }
  ]

  persistent_disks = [
    // A persistent data disk outside of the Proxmox lifecycle. This is mounted
    // inside the vm as /var/lib/postgresql for postgres
    {
      datastore_id = var.storage_data
      size = 2 # gigabytes
      iothread     = true
      discard      = "on"
      backup       = true
    }
  ]
}

