# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Syslog Server Service Policy'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Policy for NTP service (on,off,automatic)'

# The config entry stating the desired values
$Desired = $cfg.host.service_vmsyslogd_policy

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'vmsyslogd'
    }).Policy
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
   Set-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'vmsyslogd'
        }) -Policy $Desired -ErrorAction Stop
}
