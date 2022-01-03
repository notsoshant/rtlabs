using module "..\helper.psm1"

function Initialize-DCSetup {
    param (
        $config
    )
    
    $ip = $config.boxes.dc.ip
    $hostname = $config.boxes.dc.hostname
    $user = $config.boxes.dc.user
    $pass = $config.boxes.dc.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Add $hostname IP to WinRM TrustedHosts"
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ip -Concatenate -Force
    Write-Host ""

    $dc = [Setup]::new($ip, $user, $pass)

    Write-Host "[$hostname] Change Administrator password, change Hostname to $hostname and restart"
    $dc.RemoteCommand("Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)'")
    $dc.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Get-LocalUser -Name Administrator | Set-LocalUser -Password `$pass")
    $dc.RenameComputer($hostname)
    $dc.RestartComputer()
    Write-Host ""

    Write-Host "[$hostname] Install Active Directory and setup as Domain Controller"
    $dc.InstallFeature("AD-Domain-Services")
    $dc.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Install-ADDSForest -DomainName $domainname -InstallDNS -SafeModeAdministratorPassword `$pass -Force")
    Write-Host ""
}
