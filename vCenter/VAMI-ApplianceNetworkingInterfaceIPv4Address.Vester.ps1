# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.7

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter Networking Interfaces IPv4 Address'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMI com.vmware.appliance.networking.interfaces.ipv4.address'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceNetworkingInterfacesIPv4Adress

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $var = (Get-CisService -Name 'com.vmware.appliance.networking.interfaces').list()
    $var.ipv4.address
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Write-Host 'Do you really want to change this setting?'
}

# If you're really sure, you can this code for the fix
<#
[ScriptBlock]$Fix = {
    $Spec = (Get-CisService -Name 'com.vmware.appliance.networking.interfaces').list()
    $Spec.ipv4.address = $Desired
    (Get-CisService -name 'com.vmware.appliance.networking.interfaces').set($Spec)
}
#>
