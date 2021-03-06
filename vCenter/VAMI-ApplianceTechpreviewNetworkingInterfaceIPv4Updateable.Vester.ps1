# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.5

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter Networking Interfaces IPv4 Updateable'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMI com.vmware.appliance.techpreview.networking.ipv4.updateable'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceTechpreviewNetworkingIPv4Updateable

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $var = (Get-CisService -Name 'com.vmware.appliance.techpreview.networking.ipv4').list()
    $var.updateable
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Write-Host 'Do you really want to change this setting?'
}

# If you're really sure, you can this code for the fix
<#
[ScriptBlock]$Fix = {
    $Spec = (Get-CisService -Name 'com.vmware.appliance.techpreview.networking.ipv4').list()
    $Spec.updateable = $Desired
    (Get-CisService -name 'com.vmware.appliance.techpreview.networking.ipv4').set($Spec)
}
#>
