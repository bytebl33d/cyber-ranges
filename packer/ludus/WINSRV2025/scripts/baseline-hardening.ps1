# baseline-hardening.ps1
# Applies Microsoft OSConfig security baseline for Windows Server 2025
# https://learn.microsoft.com/en-us/windows-server/security/osconfig/osconfig-how-to-configure-security-baselines

param(
  [ValidateSet("MemberServer", "WorkgroupMember", "DomainController")]
  [string]$ServerRole = "WorkgroupMember"
)

Write-Host "[*] Installing OSConfig module..."
Install-Module -Name Microsoft.OSConfig -Scope AllUsers -Repository PSGallery -Force

Write-Host "[*] Verifying OSConfig installation..."
if (-not (Get-Module -ListAvailable -Name Microsoft.OSConfig)) {
  Write-Error "OSConfig module failed to install"
  exit 1
}

Write-Host "[*] Applying security baseline for role: $ServerRole"
Set-OSConfigDesiredConfiguration -Scenario "SecurityBaseline/WS2025/$ServerRole" -Default

Write-Host "[*] Applying Defender Antivirus baseline..."
Set-OSConfigDesiredConfiguration -Scenario Defender/Antivirus -Default

Write-Host "[*] Verifying baseline compliance..."
Get-OSConfigDesiredConfiguration -Scenario "SecurityBaseline/WS2025/$ServerRole" | ft Name, @{
  Name       = "Status"
  Expression = { $_.Compliance.Status }
}, @{
  Name       = "Reason"
  Expression = { $_.Compliance.Reason }
} -AutoSize -Wrap

Write-Host "[*] Baseline applied. A reboot is required for all changes to take effect."
