# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.5, 6.7

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter Access Shell Bash Enabled'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMi com.vmware.appliance.access.shell.enabled'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceAccessShellBashEnabled

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $shellAccess = (Get-CisService -Name 'com.vmware.appliance.access.shell').get()
    $shellAccess.enabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
# If .enabled = $True, then the .timeout must be specified
[ScriptBlock]$Fix = {
    $Spec = (Get-CisService -Name "com.vmware.appliance.access.shell").get()
    $Spec.enabled = $Desired
    if ($Spec.enabled) {
        $Spec.timeout = 3600 # Default timeout in seconds. Max. is one day
    }
    (Get-CisService -Name "com.vmware.appliance.access.shell").set($Spec)
}

