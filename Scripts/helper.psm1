class Helper {
    [string]$hostname
    [string]$IP
    [string]$Username
    [securestring]$Password
    [pscredential]$Credential

    Helper ([string]$hostname, [string]$IP, [string]$u, [string]$p) {
        $this.hostname = $hostname
        $this.IP = $IP
        $this.Authenticate($u, $p)
    }

    [void]Authenticate([string]$u, [string]$p) {
        $this.Username = $u
        $this.Password = ConvertTo-SecureString -String $p -AsPlainText -Force
        Write-Verbose "[Verbose][$this.hostname] Authenticating with $u"
        $this.Credential = [pscredential]::new($this.Username, $this.Password)
    }

    [void]RemoteCommand([string]$Command) {
        $ScriptBlock = [scriptblock]::Create($Command)
        $output = Invoke-Command -ComputerName $this.IP -Credential $this.Credential -ScriptBlock $ScriptBlock
        Write-Verbose "[Verbose][$this.hostname] $output"
    }

    [void]RestartComputer() {
        Restart-Computer -ComputerName $this.IP -Credential $this.Credential -Force -Wait -For WinRM
    }

    [void]RenameComputer([string]$NewName) {
        Rename-Computer -ComputerName $this.IP -LocalCredential $this.Credential -NewName $NewName
    }

    [void]InstallFeature([string]$Feature) {
        Write-Verbose "[Verbose][$this.hostname] Installing feature: $Feature"
        $this.RemoteCommand("Install-WindowsFeature -Name $Feature -IncludeAllSubFeature -IncludeManagementTools -Restart")
    }

    [void]SetDNS([string]$dcip) {
        if ($null -eq $dcip) {
            $dns = "('1.1.1.1')"
        }
        else {
            $dns = "('$dcip', '1.1.1.1')"
        }
        $this.RemoteCommand("Set-DnsClientServerAddress -InterfaceIndex (Get-NetIPAddress -InterfaceAlias *Ethernet* -AddressFamily IPv4).InterfaceIndex -ServerAddresses $dns")
    }
}

class Setup : Helper {
    Setup ([string]$hostname, [string]$IP, [string]$u, [string]$p, [string]$adminpass, [string]$dcip) : base($hostname, $IP, $u, $p) {
        $this.Prepare($adminpass, $dcip)
    }

    [void]Prepare([string]$adminpass, [string]$dnsip) {
        Write-Verbose "[Verbose][$this.hostname] Adding IP in TrustedHosts of WinRM"
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value $this.IP -Concatenate -Force

        Write-Verbose "[Verbose][$this.hostname] Setting up Static IPv4 IP"
        $this.RemoteCommand("New-NetIPAddress -InterfaceIndex (Get-NetIPAddress -InterfaceAlias *Ethernet* -AddressFamily IPv4).InterfaceIndex -IPAddress $this.IP")

        Write-Verbose "[Verbose][$this.hostname] Disabling IPv6"
        $this.RemoteCommand("Enable-NetAdapterBinding -Name `"*`" -ComponentID ms_tcpip6")

        Write-Verbose "[Verbose][$this.hostname] Changing DNS"
        $this.SetDNS($dnsip)

        Write-Verbose "[Verbose][$this.hostname] Modifying Firewall rule to allow WMI"
        $this.RemoteCommand("Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)'")

        Write-Verbose "[Verbose][$this.hostname] Changing Administrator Password"
        $this.RemoteCommand("`$pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force; Get-LocalUser -Name Administrator | Set-LocalUser -Password `$pass")

        Write-Verbose "[Verbose][$this.hostname] Renaming Computer"
        $this.RenameComputer($this.hostname)
        $this.RestartComputer()
    }

    [void]JoinDomain([string]$domain, [string]$adminpass) {
        $pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force
        $d = $domain.split(".")[0].ToUpper()
        $cred = [pscredential]::new("$d\Administrator", $pass)
        Write-Verbose "[Verbose][$this.hostname] Adding $this.hostname to domain $domain"
        Add-Computer -ComputerName $this.IP -LocalCredential $this.Credential -DomainCredential $cred -DomainName $domain
    }
}