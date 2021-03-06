# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.5, 6.7

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter SNMP Enable'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMI com.vmware.appliance.techpreview.monitoring.snmp'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceTechpreviewMonitoringSnmpEnable

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $var = (Get-CisService -Name 'com.vmware.appliance.techpreview.monitoring.snmp').get()
    $var.enable
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Spec = (Get-CisService -Name 'com.vmware.appliance.networking.dns.domains').get()
    $Spec.enable = $Desired
    (Get-CisService -Name 'com.vmware.appliance.networking.dns.domains').set($Spec)
}

