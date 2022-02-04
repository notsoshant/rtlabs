using module "..\helper.psm1"

function Invoke-Setup {
    param (
        $config
    )

    $ip = $config.boxes.box.ip
    $hostname = $config.boxes.box.hostname
    $user = $config.boxes.box.user
    $pass = $config.boxes.box.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Initializing Setup"
    $box = [Setup]::new($hostname, $ip, $user, $pass, $adminpass, $config.boxes.dc.ip)

    Write-Verbose "[$hostname] Join $domainname domain"
    $box.JoinDomain($domainname, $adminpass)
    $box.RestartComputer()
    
    Write-Host "[$hostname] Setup finished"
}
