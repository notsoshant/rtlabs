using module "..\helper.psm1"

function Initialize-SRV01Setup {
    param (
        $config
    )

    $ip = $config.boxes.srv01.ip
    $hostname = $config.boxes.srv01.hostname
    $user = $config.boxes.srv01.user
    $pass = $config.boxes.srv01.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Add $hostname IP to WinRM TrustedHosts"
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ip -Concatenate -Force
    Write-Host ""

    $srv01 = [Setup]::new($ip, $user, $pass)

    Write-Host "[$hostname] Change Administrator password"
    $srv01.RemoteCommand("Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)'")
    $srv01.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Get-LocalUser -Name Administrator | Set-LocalUser -Password `$pass")
    Write-Host ""

    Write-Host "[$hostname] Join $domainname domain while changing the hostname to $hostname"
    $srv01.SetDNSToDC($config.boxes.dc.ip)
    $srv01.RenameComputer($hostname)
    $srv01.RestartComputer()
    $d = $domainname.split(".")[0].ToUpper()
    $srv01.JoinDomain($d, $adminpass)
    $srv01.RestartComputer()
    $srv01.Authenticate("$d\Administrator", $adminpass)
    Write-Host ""

    Write-Host "[$hostname] Install IIS"
    $srv01.InstallFeature("Web-Server")
    Write-Host ""
}
