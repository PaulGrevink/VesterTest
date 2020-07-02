# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vCSA 6.7

# Test title, e.g. 'DNS Servers'
$Title = 'vCenter Appliance Logging Forwarding'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VAMi com.vmware.appliance.logging.forwarding'
# Default value = not available

# The config entry stating the desired values
$Desired = $cfg.vcenter.applianceLoggingForwarding

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    if ((Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().count -eq 1) {
        # Get single line with hostname, port and protocol
        (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().hostname        (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().port        (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().protocol    
    } else {
        # Get 2 or 3 lines.
        $i = 0        while ($i -lt (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().count){            (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().hostname[$i]            (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().port[$i]            (Get-CisService -name 'com.vmware.appliance.logging.forwarding').get().protocol[$i]            $i ++
        }
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $speclist = [System.Collections.Generic.List[PSobject]]::new()
    $i=0
    while ($i -lt $Desired.count){
        $spec = New-Object PSObject -Property @{
            hostname=$Desired[$i]
            port=$Desired[$i+1]
            protocol=$Desired[$i+2]
        }
        $speclist.add($spec)
        $i=$i+3
    }
    (Get-CisService -name 'com.vmware.appliance.logging.forwarding').set($speclist)
}