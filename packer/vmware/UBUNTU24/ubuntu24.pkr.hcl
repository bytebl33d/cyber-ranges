packer {
  required_version = ">= 1.10.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.11"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

# --- Variables ---
variable "iso_path" {
  type        = string
  description = "Absolute path to Ubuntu 22.04 ISO"
}
variable "iso_checksum" {
  type    = string
  default = "none"
}
variable "output_dir" {
  type    = string
  default = "../../boxes/Ubuntu2404"
}
variable "disk_size_mb" {
  type    = number
  default = 10240
}
variable "memory_mb" {
  type    = number
  default = 2048
}
variable "cpus" {
  type    = number
  default = 2
}
variable "ssh_username" {
  type    = string
  default = "sysadmin"
}
variable "ssh_password" {
  type      = string
  default   = "MyStr0ng!Pass"
  sensitive = true
}

# --- Source ---
source "vmware-iso" "Ubuntu2404" {
  vm_name       = "Ubuntu2404"
  guest_os_type = "ubuntu-64"

  iso_url      = var.iso_path
  iso_checksum = var.iso_checksum

  disk_size = var.disk_size_mb
  memory    = var.memory_mb
  cpus      = var.cpus

  network_adapter_type = "vmxnet3"

  # Ubuntu uses cloud-init autoinstall
  cd_files = [
    "./http/meta-data",
    "./http/user-data"
  ]
  cd_label = "cidata"

  boot_wait = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud ---",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  communicator     = "ssh"
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "30m"

  output_directory = var.output_dir
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  shutdown_timeout = "15m"

  # Export configuration
  format          = "vmx"
  skip_compaction = false
}

# --- Build ---
build {
  name    = "Ubuntu2204"
  sources = ["source.vmware-iso.Ubuntu2404"]

  # Wait for cloud-init to fully finish
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done"
    ]
  }

  # Baseline hardening
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh",

      "sudo ln -sf /dev/null /root/.bash_history",
      "sudo ln -sf /dev/null /root/.mysql_history",
      "sudo ln -sf /dev/null /root/.viminfo",
      "sudo chown root:root /root/.bash_history",
      "sudo chown root:root /root/.mysql_history",
      "sudo chown root:root /root/.viminfo",

      "sudo ln -sf /dev/null /home/${var.ssh_username}/.bash_history",
      "sudo chown root:${var.ssh_username} /home/${var.ssh_username}/.bash_history",

      "sudo tee /etc/netplan/00-installer-config.yaml > /dev/null <<'EOF'\nnetwork:\n    version: 2\n    ethernets:\n        ens160:\n            dhcp4: true\nEOF",
      "sudo chmod 600 /etc/netplan/00-installer-config.yaml",
      "sudo netplan apply",
    ]
  }

  # Disable automatic updates
  provisioner "shell" {
    inline = [
      "sudo systemctl disable apt-daily.timer apt-daily-upgrade.timer",
      "sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer",
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    scripts = [
      "scripts/post-install.sh"
    ]
  }
}