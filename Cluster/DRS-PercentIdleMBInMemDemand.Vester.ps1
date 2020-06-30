# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS Memory Metric for Load Balancing'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Load balance based on consumed memory of VMs or active memory'
# The valid values are: [int] -1 or 100
# A value of 100: Load balance of VMs based on consumed memory. 
# This setting is only recommended for clusters where host memory is not over-committed.
#
# A value of -1: Load balance of VMs based on active memory + percent of idle memory

# The config entry stating the desired values
$Desired = $cfg.cluster.drsmemoryloadbalancing

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    if (Get-AdvancedSetting -Entity $object -Name PercentIdleMBInMemDemand) {
        (Get-AdvancedSetting -Entity $object -Name PercentIdleMBInMemDemand).Value
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
        Get-AdvancedSetting -Entity $object -Name PercentIdleMBInMemDemand | Remove-AdvancedSetting -Confirm:$false -ErrorAction Stop
    } else {
        if (Get-AdvancedSetting -Entity $object -Name PercentIdleMBInMemDemand) {
            # Setting exist, assign new value
            Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
                $_.Name -eq 'PercentIdleMBInMemDemand'
            } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop      
       } else {
           # Setting must be created
           $Object | New-AdvancedSetting -Name PercentIdleMBInMemDemand -Value $Desired -Force -Confirm:$false -ErrorAction Stop
       }
    }
}