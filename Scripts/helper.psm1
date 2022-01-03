class Setup {
    [string]$IP
    [string]$Username
    [securestring]$Password
    [pscredential]$Credential

    Setup ([string]$IP, [string]$u, [string]$p) {
        $this.IP = $IP
        $this.Authenticate($u, $p)
    }

    [void]Authenticate([string]$u, [string]$p) {
        $this.Username = $u
        $this.Password = ConvertTo-SecureString -String $p -AsPlainText -Force
        $this.Credential = [pscredential]::new($this.Username, $this.Password)
    }

    [void]RemoteCommand([string]$Command) {
        $ScriptBlock = [scriptblock]::Create($Command)
        Invoke-Command -ComputerName $this.IP -Credential $this.Credential -ScriptBlock $ScriptBlock
    }

    [void]RestartComputer() {
        Restart-Computer -ComputerName $this.IP -Credential $this.Credential -Force -Wait -For WinRM
    }

    [void]RenameComputer([string]$NewName) {
        Rename-Computer -ComputerName $this.IP -LocalCredential $this.Credential -NewName $NewName
    }

    [void]InstallFeature([string]$Feature) {
        $this.RemoteCommand("Install-WindowsFeature -Name $Feature -IncludeAllSubFeature -IncludeManagementTools -Restart")
    }

    [void]JoinDomain([string]$domain, [string]$adminpass) {
        $pass = ConvertTo-SecureString -String $adminpass -AsPlainText -Force
        $cred = [pscredential]::new("$domain\Administrator", $pass)
        Add-Computer -ComputerName $this.IP -LocalCredential $this.Credential -DomainCredential $cred -DomainName $domain
    }

    [void]SetDNSToDC([string]$dcip) {
        $this.RemoteCommand("Set-DnsClientServerAddress -InterfaceIndex (Get-NetIPAddress -InterfaceAlias *Ethernet* -AddressFamily IPv4).InterfaceIndex -ServerAddresses ('$dcip')")
    }
}