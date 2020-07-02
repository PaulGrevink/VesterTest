# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Network adapter Physical settings (NIC)'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the physical network adapter settings'

# The config entry stating the desired values
$Desired = $cfg.host.nic

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ("Name;AdminStatus;Driver;Duplex;Link;LinkStatus;MTU;Speed;RSS;RxDesc;TxDes;Rx;RXJumbo;RXMini;TX")
    $esxcli = Get-EsxCli -VMHost $Object -v2
    $esxcli.network.nic.list.invoke()  | ForEach-Object {
        $ixgben_RSS = ""
        $ixgben_RxDesc = ""
        $ixgben_TxDesc = ""
        if ($_.Driver -eq "ixgben") {
            $arguments = $esxcli.system.module.parameters.list.CreateArgs()
            $arguments.module = "ixgben"
            $ixgben_parameters = $esxcli.system.module.parameters.list.Invoke($arguments)
            $ixgben_RSS    = $ixgben_parameters | ? {$_.Name -eq "RSS"}    | select -ExpandProperty Value
            $ixgben_RxDesc = $ixgben_parameters | ? {$_.Name -eq "RxDesc"} | select -ExpandProperty Value
            $ixgben_TxDesc = $ixgben_parameters | ? {$_.Name -eq "TxDesc"} | select -ExpandProperty Value
        }
        $arguments = $esxcli.network.nic.ring.current.get.CreateArgs()
        $arguments.nicname = $_.Name
        $NicRingSettings = $esxcli.network.nic.ring.current.get.Invoke($arguments)
        ($_.Name+";"+$_.AdminStatus+";"+$_.Driver+";"+$_.Duplex+";"+
        $_.Link+";"+$_.LinkStatus+";"+$_.MTU+";"+$_.Speed+";"+
        $ixgben_RSS+";"+$ixgben_RxDesc+";"+$ixgben_TxDesc+";"+
        $NicRingSettings.RX+";"+$NicRingSettings.RXJumbo+";"+
        $NicRingSettings.RXMini+";"+$NicRingSettings.TX)
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Write-Host "Differences in NIC settings, manual action required"
}
