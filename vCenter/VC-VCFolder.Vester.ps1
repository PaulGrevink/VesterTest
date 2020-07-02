# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VCFolder'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Checks all vCenter Folders'

# The config entry stating the desired values
$Desired = $cfg.vcenter.VcFolder

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $array = Get-View -ViewType Folder | select Name,Moref,Parent
    $array += Get-View -ViewType Datacenter | select Name,Moref,Parent
    $array | ForEach-Object {
        $myout = ""
        $folder =$_.Name
        $parent = $_.Parent
        while ($folder -notlike "DataCenters") {
            $myout = $myout+"/"+$folder
            $folder = ($array | Where-Object { $_.Moref -eq $parent}).Name
            $parent = ($array | Where-Object { $_.Moref -eq $parent}).Parent
        }
        $myout
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Write-Host "vCenter folder structure has changed."
}
