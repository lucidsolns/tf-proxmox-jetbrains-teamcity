terraform {
  required_version = "~> 1.5.0"
}
/*
    Jetbrains Hub (deployed as a container on Flatcar Linux)

    Before creating the VM, the following ZFS based directory is used for Teamcity data:
      zfs create -o quota=10G -o mountpoint=/droplet/data/jetbrains-teamcity-data droplet/141-olive-jetbrains-teamcity-data
    The data directory is put into the Flatcar Linux VM using plan9fs, then it
    is mounted using 2 paths into the hub docker container.

    And the following zvol is used for postgre SQL data:
      zfs create -s -V 8G droplet/vm-141-olive-jetbrains-teamcity-pgdata
    The ZFS zvol is mounted the VM and directly mapped into the PGSQL container.

*/
module "olive" {
  source        = "lucidsolns/proxmox/vm"
  version       = ">= 0.0.6"
  vm_id         = 141
  name          = "olive.lucidsolutions.co.nz"
  description   = <<-EOT
      Jetbrains Teamcity running as a container on Flatcar Linux with plan9fs for data/logs/conf/backup
  EOT
  startup       = "order=80"
  tags          = ["flatcar", "jetbrains", "teamcity", "development"]
  pm_api_url    = var.pm_api_url
  target_node   = var.target_node
  pm_user       = var.pm_user
  pm_password   = var.pm_password
  template_name = "flatcar-production-qemu-3602.2.1"
  butane_conf   = "${path.module}/jetbrains-teamcity.bu.tftpl"
  memory        = 4096
  networks      = [{ bridge = var.bridge, tag = 120 }]
  plan9fs       = [
    {
      dirid = "/droplet/data/jetbrains-teamcity-data"
      tag   = "teamcity-data"
    }
  ]
  disks         = [
    // The flatcar EFI/boot/root/... template disk. This is a placeholder to
    // stop the proxmox provider from getting too confused.
    {
      slot    = 0
      type    = "scsi"
      size    = "0K" # no size, we don't want the template resized
      storage = "local"
      format  = "qcow2"
    },

    // A non-persistent sparse disk for swap, this is /dev/vda in the VM
    {
      slot    = 1
      type    = "virtio"
      storage = "vmdata" # hack, this must be 'present'
      size    = "4G" # hack, this must be present
      format  = "raw"
      discard = "on" # enable 'trim' support, as ZFS supports this
    },

    // A persistent data disk outside of the Proxmox lifecycle
    //
    // Create the zvol with:
    //    zfs create -s -V 8G droplet/vm-141-olive-jetbrains-teamcity-pgdata
    {
      slot    = 2
      type    = "virtio"
      storage = "format=raw" # hack, this must be 'present'
      size    = "0K" # hack, disable trying to size the volume
      volume  = "/dev/zvol/droplet/vm-141-olive-jetbrains-teamcity-pgdata"
      format  = "raw" # default
      discard = "on" # enable 'trim' support, as ZFS supports this
    }
  ]
}

