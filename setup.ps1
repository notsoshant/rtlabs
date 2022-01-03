Import-Module .\Scripts\machines.ps1
Import-Module .\Scripts\attacks.ps1

$config = Get-Content ".\config.json" -Raw | ConvertFrom-Json
$oldTrustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value

Write-Host "[i] Firing up Domain Controller first"
vagrant up dc
Start-Job -InitializationScript { Import-Module .\Scripts\Machines\dc.ps1 } -ScriptBlock { Initialize-DCSetup $using:config }
Write-Host "[i] Server up, setting up domain in background..."

Write-Host "[i] Setting up other machines"
vagrant up
Initialize-MachineSetup $config
Write-Host "[i] Other machines configured"

Write-Host "[i] Configure Attacks on Domain"
Install-Attacks $config
Write-Host ""

Write-Host "[i] Restore the TrustedHosts value"
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $oldTrustedHosts -Concatenate -Force
Write-Host "[i] Exiting... Take a snapshot if you like"
