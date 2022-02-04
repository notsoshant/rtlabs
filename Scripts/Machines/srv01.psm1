using module "..\helper.psm1"

function Invoke-Setup {
    param (
        $config
    )

    $ip = $config.boxes.srv01.ip
    $hostname = $config.boxes.srv01.hostname
    $user = $config.boxes.srv01.user
    $pass = $config.boxes.srv01.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Initializing Setup"
    $srv01 = [Setup]::new($hostname, $ip, $user, $pass, $adminpass, $config.boxes.dc.ip)

    Write-Verbose "[$hostname] Join $domainname domain"
    $srv01.JoinDomain($domainname, $adminpass)
    $srv01.RestartComputer()
    $srv01.Authenticate("$d\Administrator", $adminpass)

    Write-Verbose "[$hostname] Setup IIS"
    $srv01.InstallFeature("Web-Server")
    Write-Host "[$hostname] Setup finished"
}
