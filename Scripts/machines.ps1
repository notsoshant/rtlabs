Import-Module .\Scripts\Machines\dc.ps1
Import-Module .\Scripts\Machines\srv01.ps1
Import-Module .\Scripts\Machines\srv02.ps1
Import-Module .\Scripts\Machines\wkt01.ps1

function Initialize-MachineSetup {
    param (
        $config
    )

    Initialize-SRV01Setup $config
    Initialize-SRV02Setup $config
    Initialize-WKT01Setup $config
}
