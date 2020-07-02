# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# Test title, e.g. 'DNS Servers'
$Title = 'task.maxAgeEnabled'
# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enable event cleanup'
# Default value = not available
# The config entry stating the desired values
$Desired = $cfg.vcenter.taskmaxAgeEnabled
# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'
# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'task.maxAgeEnabled'
    }).Value
}
# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'task.maxAgeEnabled'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}

