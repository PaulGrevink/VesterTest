# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VCPermissions'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Checks vCenter permissions'

# The config entry stating the desired values
$Desired = $cfg.vcenter.VcPermissions

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ("EntityId;Entity;Role;Principal;Propagate;IsGroup")
    Get-VIPermission | ForEach-Object {
        ($_.EntityId+";"+$_.Entity+";"+$_.Role+";"+
         $_.Principal+";"+$_.Propagate+";"+$_.IsGroup)
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Write-Host "vCenter permissions has changed"
}
