# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.7

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter Local Accounts Policy - Min Days'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMi com.vmware.appliance.local_accounts.policy - min_days'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceLocal_accountsPolicyMin_days

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $var = (Get-CisService -name 'com.vmware.appliance.local_accounts.policy').get()
    $var.min_days
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Spec = (Get-CisService -name 'com.vmware.appliance.local_accounts.policy').get()
    $Spec.min_days = $Desired
    (Get-CisService -name 'com.vmware.appliance.local_accounts.policy').set($Spec)

}
