﻿# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VSAN Disk Claim mode'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the mode by which disks are claimed by the Virtual SAN'
# The valid values are: Manual, ???

# The config entry stating the desired values
$Desired = $cfg.cluster.vsandiskclaimmode

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.VsanDiskClaimMode
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-Cluster -Cluster $Object -VsanDiskClaimMode:$Desired -Confirm:$false -ErrorAction Stop
}
