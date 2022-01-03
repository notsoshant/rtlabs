using module "..\helper.psm1"

function Initialize-WKT01Setup {
    param (
        $config
    )

    $ip = $config.boxes.wkt01.ip
    $hostname = $config.boxes.wkt01.hostname
    $user = $config.boxes.wkt01.user
    $pass = $config.boxes.wkt01.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Add $hostname IP to WinRM TrustedHosts"
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ip -Concatenate -Force
    Write-Host ""

    $wkt01 = [Setup]::new($ip, $user, $pass)

    Write-Host "[$hostname] Change Administrator password"
    $wkt01.RemoteCommand("Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)'")
    $wkt01.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Get-LocalUser -Name Administrator | Set-LocalUser -Password `$pass")
    Write-Host ""

    Write-Host "[$hostname] Join $domainname domain while changing the hostname to $hostname"
    $wkt01.SetDNSToDC($config.boxes.dc.ip)
    $wkt01.RenameComputer($hostname)
    $wkt01.RestartComputer()
    $d = $domainname.split(".")[0].ToUpper()
    $wkt01.JoinDomain($d, $adminpass)
    $wkt01.RestartComputer()
    $wkt01.Authenticate("$d\Administrator", $adminpass)
    Write-Host ""
}
