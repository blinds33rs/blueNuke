# Restart BT Service

# Requires 
$cred = Get-Credential
Start-Process -FilePath "services.msc" -Credential $cred

# Get all Bluetooth and USB adapters
$adapters = Get-WmiObject -Class "Win32_PNPEntity" -Filter "DeviceID like 'USB%' or DeviceID like 'BTH%'"

# Create log file
$logfile = "bluetooth_reset_log.txt"
New-Item $logfile -ItemType file -Force


$bthService = Get-Service -Name "bthserv"
if ($bthService.Status -eq "Running") {
    Restart-Service -Name "bthserv"
    Write-Host "Bluetooth service has been restarted successfully."
# Sets Device to Autumatic from state

} else {
    Start-Service -Name "bthserv"
    $bthService = Get-Service -Name "bthserv"
    $bthService.StartType = "Automatic"
    $bthService | Set-Service
    Write-Host "Bluetooth service has been started and set to Automatic."
}

# Finds Paired Devices and retrieves name and status 
$bthDevices = Get-PnpDevice -Class Bluetooth
foreach ($device in $bthDevices) {
    $status = $device.Status
    $name = $device.DeviceName
    Write-Host "Device: $name, Status: $status"
}

# Disable and then enable each adapter, and record the operation in the log file
foreach ($adapter in $adapters) {
    $deviceInstanceId = $adapter.DeviceID
    Disable-NetAdapter -InterfaceDescription $deviceInstanceId
    Add-Content -Path $logfile -Value "Disabled $deviceInstanceId"
    Enable-NetAdapter -InterfaceDescription $deviceInstanceId
    Add-Content -Path $logfile -Value "Enabled $deviceInstanceId"
}

# Restart the computer
# Restart-Computer
# Add-Content -Path $logfile -Value "Restarted computer"