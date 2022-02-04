using module "..\helper.psm1"

function Invoke-Setup {
    param (
        $config
    )
    
    $ip = $config.boxes.dc.ip
    $hostname = $config.boxes.dc.hostname
    $user = $config.boxes.dc.user
    $pass = $config.boxes.dc.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Initializing Setup"
    $dc = [Setup]::new($hostname, $ip, $user, $pass, $adminpass, $null)

    Write-Verbose "[$hostname] Install Active Directory and setup as Domain Controller"
    $dc.InstallFeature("AD-Domain-Services")
    $dc.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Install-ADDSForest -DomainName $domainname -InstallDNS -SafeModeAdministratorPassword `$pass -Force")
    Write-Host "[$hostname] Setup finished"
}
