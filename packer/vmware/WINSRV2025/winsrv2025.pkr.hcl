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
  description = "Absolute path to your Windows Server 2025 ISO"
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum of the ISO (prefix with 'sha256:')"
  default     = "none"
}

variable "output_dir" {
  type    = string
  default = "../../boxes/WINSRV2025"
}

variable "disk_size_mb" {
  type    = number
  default = 61440 # 60 GB
}

variable "memory_mb" {
  type    = number
  default = 4096
}

variable "cpus" {
  type    = number
  default = 2
}

variable "winrm_username" {
  type    = string
  default = "Administrator"
}

variable "winrm_password" {
  type      = string
  default   = "MyStr0ng!Pass"
}

# --- Source ---

source "vmware-iso" "WINSRV2025" {
  # VM identity
  vm_name      = "WINSRV2025"
  guest_os_type = "windows2022srvNext-64"

  # ISO
  iso_url      = var.iso_path
  iso_checksum = var.iso_checksum

  # Hardware
  disk_size    = var.disk_size_mb
  memory       = var.memory_mb
  cpus         = var.cpus
  network_adapter_type = "vmxnet3"

  # Unattended install answer file served over HTTP
  http_directory = "http"
  floppy_files   = ["http/Autounattend.xml"]

  # Boot
  boot_wait    = "5s"
  boot_command = ["<spacebar>"]

  # WinRM communicator (Autounattend enables it)
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_timeout  = "90m"
  winrm_use_ssl  = false

  # Output
  output_directory = var.output_dir
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer shutdown\""
  shutdown_timeout = "15m"

  # VMware-specific
  vmx_data = {
    "virtualHW.version"     = "21"   # VMware Workstation 17
    "ethernet0.virtualDev"  = "vmxnet3"
    "scsi0.virtualDev"      = "lsisas1068"
    # Nested virtualization
    "vhv.enable"            = "TRUE"
    "vpmc.enable"           = "TRUE"
  }
}

# --- Build ---

build {
  name    = "WINSRV2025"
  sources = ["source.vmware-iso.WINSRV2025"]

  # Update PowerShell help (suppress first-run noise)
  provisioner "powershell" {
    inline = ["Update-Help -Force -ErrorAction SilentlyContinue"]
  }

  # Disable Windows Firewall for lab (re-enable if you want detection practice)
  provisioner "powershell" {
    inline = [
      "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False",
    ]
  }

  # Enable WinRM permanently (Autounattend only enables it temporarily)
  provisioner "powershell" {
    inline = [
      "winrm quickconfig -q",
      "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"512\"}'",
      "winrm set winrm/config '@{MaxTimeoutms=\"1800000\"}'",
      "winrm set winrm/config/service '@{AllowUnencrypted=\"true\"}'",
      "winrm set winrm/config/service/auth '@{Basic=\"true\"}'",
      "Set-Service -Name WinRM -StartupType Automatic",
    ]
  }

  # Disable Windows Update (keep lab stable)
  provisioner "powershell" { 
    inline = [
      "Set-Service -Name wuauserv -StartupType Disabled",
      "Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue",
    ]
  }

  # Activate Windows
  provisioner "powershell" {
    inline = [
      "& ([ScriptBlock]::Create((irm https://get.activated.win))) /TSforge /Z-Windows",
    ]
  }

  # Apply baseline hardening (OSConfig)
  provisioner "powershell" {
    inline = [
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false",
      "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted",
      "Install-Module -Name Microsoft.OSConfig -Scope AllUsers -Repository PSGallery -Force -Confirm:$false",
      "Set-OSConfigDesiredConfiguration -Scenario SecurityBaseline/WS2025/WorkgroupMember -Default",
      "Set-OSConfigDesiredConfiguration -Scenario Defender/Antivirus -Default",
    ]
  }
}
