﻿# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'CIM Server (sfcbd) Service State'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'On/off switch for CIM Server service'

# The config entry stating the desired values
$Desired = $cfg.host.service_sfcbd_running

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'sfcbd-watchdog'
    }).Running
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ($Desired -eq $true) 
    {
        Start-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'sfcbd-watchdog'
        }) -ErrorAction Stop -Confirm:$false
    }
    if ($Desired -eq $false) 
    {
        Stop-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'sfcbd-watchdog'
        }) -ErrorAction Stop -Confirm:$false
    }
}
