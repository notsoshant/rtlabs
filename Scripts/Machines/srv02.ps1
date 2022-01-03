using module "..\helper.psm1"

function Initialize-SRV02Setup {
    param (
        $config
    )

    $ip = $config.boxes.srv02.ip
    $hostname = $config.boxes.srv02.hostname
    $user = $config.boxes.srv02.user
    $pass = $config.boxes.srv02.pass
    $adminpass = $config.adminpass
    $domainname = $config.domain

    Write-Host "[$hostname] Add $hostname IP to WinRM TrustedHosts"
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ip -Concatenate -Force
    Write-Host ""

    $srv02 = [Setup]::new($ip, $user, $pass)

    Write-Host "[$hostname] Change Administrator password"
    $srv02.RemoteCommand("Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)'")
    $srv02.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Get-LocalUser -Name Administrator | Set-LocalUser -Password `$pass")
    Write-Host ""

    Write-Host "[$hostname] Join $domainname domain while changing the hostname to $hostname"
    $srv02.SetDNSToDC($config.boxes.dc.ip)
    $srv02.RenameComputer($hostname)
    $srv02.RestartComputer()
    $d = $domainname.split(".")[0].ToUpper()
    $srv02.JoinDomain($d, $adminpass)
    $srv02.RestartComputer()
    $srv02.Authenticate("$d\Administrator", $adminpass)
    Write-Host ""
}
