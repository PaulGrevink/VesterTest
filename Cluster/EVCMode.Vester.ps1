# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# 20200123 previous version returned $null when not configured. 
# Now shows 'EVC is not configured'

# Test title, e.g. 'DNS Servers'
$Title = $Title = 'EVC Mode'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the VMware Enhanced vMotion Compatibility (EVC) mode'
# The valid values are: 

# The config entry stating the desired values
$Desired = $cfg.cluster.EVCMode

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    if ($Object.EVCMode -ne $null) {
        $Object.EVCMode
    } else {
        'EVC is not configured'
    }

}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-Cluster -Cluster $Object -EVCMode:$Desired -Confirm:$false -ErrorAction Stop
}
