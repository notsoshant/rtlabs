$config = Get-Content ".\config.json" -Raw | ConvertFrom-Json
$config.boxes | Get-Member -MemberType NoteProperty | ForEach-Object {
    $key = $_.Name
    $mod = $config.boxes.$key.module

    if ($key -ne "dc" -and $null -ne $mod) {
        $module = Import-Module -Name $mod -AsCustomObject -Passthru
        # $module."Invoke-Setup"($config)
    }
}