# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.7

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter NTP'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMI com.vmware.appliance.ntp'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceNtp

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-CisService -Name 'com.vmware.appliance.ntp').get()
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    (Get-CisService -Name 'com.vmware.appliance.ntp').set($Desired)
}
