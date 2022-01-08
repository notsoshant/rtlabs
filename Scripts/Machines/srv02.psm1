using module "..\helper.psm1"

function Invoke-Setup {
    param (
        $config
    )

    $ip = $config.boxes.srv02.ip
    $hostname = $config.boxes.srv02.hostname
    $user = $config.boxes.srv02.user
    $pass = $config.boxes.srv02.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Initializing Setup"
    $srv02 = [Setup]::new($hostname, $ip, $user, $pass, $adminpass, $config.boxes.dc.ip)

    Write-Verbose "[$hostname] Join $domainname domain"
    $srv02.JoinDomain($domainname, $adminpass)
    $srv02.RestartComputer()
    Write-Host "[$hostname] Setup finished"
}
