using module "..\helper.psm1"

function Invoke-Setup {
    param (
        $config
    )

    $ip = $config.boxes.wkt01.ip
    $hostname = $config.boxes.wkt01.hostname
    $user = $config.boxes.wkt01.user
    $pass = $config.boxes.wkt01.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Initializing Setup"
    $wkt01 = [Setup]::new($hostname, $ip, $user, $pass, $adminpass, $config.boxes.dc.ip)

    Write-Verbose "[$hostname] Join $domainname domain"
    $wkt01.JoinDomain($domainname, $adminpass)
    $wkt01.RestartComputer()
    Write-Host "[$hostname] Setup finished"
}
