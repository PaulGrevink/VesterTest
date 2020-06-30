# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS IgnoreAffinityRulesForMaintenance'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'SDRS Advanced - IgnoreAffinityRulesForMaintenance'
# The valid values are: [int] -1, 0 or  1
# A value of -1 will remove the setting

# The config entry stating the desired values
$Desired = $cfg.dscluster.IgnoreAffinityRulesForMaintenance

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    if (Get-AdvancedSetting -Entity $object -Name IgnoreAffinityRulesForMaintenance) {
        (Get-AdvancedSetting -Entity $object -Name IgnoreAffinityRulesForMaintenance).Value
    }
    else {
        -1
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ($Desired -eq '-1') {
        # Setting must be removed
        Get-AdvancedSetting -Entity $object -Name IgnoreAffinityRulesForMaintenance | Remove-AdvancedSetting -Confirm:$false -ErrorAction Stop
    } else {
        if (Get-AdvancedSetting -Entity $object -Name IgnoreAffinityRulesForMaintenance) {
            # Setting exist, assign new value
            Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
                $_.Name -eq 'IgnoreAffinityRulesForMaintenance'
            } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop      
       } else {
           # Setting must be created
           $Object | New-AdvancedSetting -Name IgnoreAffinityRulesForMaintenance -Value $Desired -Force -Confirm:$false -ErrorAction Stop
       }
    }
}