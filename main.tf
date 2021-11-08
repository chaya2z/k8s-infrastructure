terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://chaya2z@192.168.0.12/system"
}

resource "libvirt_volume" "ubuntu" {
  name = "ubuntu-qcow2"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

resource "libvirt_volume" "master" {
  name = "master.qcow2"
  base_volume_id = libvirt_volume.ubuntu.id
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_domain" "master" {
  description = "master node domain"
  name = "master"
  memory = 8192
  vcpu = 4

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.master.id
  }

  network_interface {
    network_name = "default"
  }

  console {
    type = "pty"
    target_port = "0"
    target_type = "virtio"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}