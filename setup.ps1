Import-Module .\Scripts\machines.psm1 -Force
Import-Module .\Scripts\attacks.psm1 -Force

$config = Get-Content ".\config.json" -Raw | ConvertFrom-Json
$oldTrustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
$natdevice = $config.natdevice

$vmnetip = (Get-NetIPAddress -InterfaceAlias "*$natdevice*" -AddressFamily IPv4).IPAddress.Split(".")[0..2]
$vmwaresubnet = $vmnetip -join "."
$jsonip = $config.boxes.dc.ip.Split(".")[0..2]
$jsonsubnet = $jsonip -join "."
if ($vmwaresubnet -ne $jsonsubnet) {
    Write-Verbose "[i] Updating IP Addresses as per VMWare NAT interface"
    $config.boxes | Get-Member -MemberType NoteProperty | ForEach-Object {
        $ip = $config.boxes.($_.Name).ip.Split(".")[3]
        $config.boxes.($_.Name).ip = "$vmwaresubnet.$ip"
    }
    ConvertTo-Json $config | Out-File ".\config.json"
}

Write-Host "[i] Firing up Domain Controller first"
$output = vagrant up dc
Write-Verbose "[Verbose] $output"
$job = Start-Job -ScriptBlock { $module = Import-Module $using:config.boxes.dc.module -AsCustomObject -Passthru -Force; $module."Invoke-Setup"($using:config) }
Write-Host "[i] DC up, setting up domain in background..."

Write-Host "[i] Setting up other machines"
$output = vagrant up
Write-Verbose "[Verbose] $output"
$job | Wait-Job
Invoke-MachineSetup $config
Write-Host "[i] Other machines configured"

Write-Host "[i] Configure Attacks on Domain"
Install-Attacks $config

Write-Host "[i] Restore the TrustedHosts value"
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $oldTrustedHosts -Concatenate -Force
Write-Host "[i] Exiting... Take a snapshot if you like"
