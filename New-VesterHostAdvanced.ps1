function New-VesterHostAdvanced {
    <#
    .SYNOPSIS
       Create Vester Test files for Advanced Settings of an ESXi host.

    .DESCRIPTION
       Script generates a set of Vester Test files for all available
       advancedsettings of an ESXi host.
       This is done by connecting to a vCenter Server and selecting
       one of the available ESXi hosts to collect all Advanced Settings
       As all advanced settings can be read and changed with the
       Get-AdvancedSetting and Set-AdvancedSetting cmdlets, scripts can 
       be generated using a here document and some replacements.

    .SYNTAX
       New-VesterHostAdvanced [[-Server] <Object>] [<CommonParameters>]

    .EXAMPLE
       PS C:\> New-VesterHostAdvanced -Server vc06.virtual.local
       Connects to a vCenter Server

    #>
    [CmdletBinding()]
    Param (
        # FQDN or IP address of a vCenter Server
        [Parameter(Mandatory=$true,
                   Position=0)]
        $Server
    )

    Begin
    {
        if (!$creds) {$creds = Get-Credential "administrator@vsphere.local"}
        
        try
        {
            Connect-VIServer -Server $Server -Credential $creds -ErrorAction Stop
            # Skip these parameters
            $skip = @('ScratchConfig.CurrentScratchLocation',
                      'ScratchConfig.ConfiguredScratchLocation',
                      'Vpx.Vpxa.config.vpxa.hostIp',
                      'Vpx.Vpxa.config.vpxa.hostKey'
                     )
        }
        catch
        {
            Write-Host "vCenter Server $Server not reachable. Try again"
            exit
        }
       
    }
    Process
    {
        Write-Verbose "Starting process"
        $i = 0
        $VMhosts = Get-VMHost | Sort-Object Name
        foreach ($VMhost in $VMhosts) {
            Write-Host "$i - $($VMhosts[$i].Name)"
            $i++
        }
        $j = Read-Host "Select Host, enter number"        # input validation $j must >=0 AND <$i        Write-Host "Host selected is $($VMhosts[$j])"

        $Settings = Get-AdvancedSetting -Entity $($VMhosts[$j]) | Sort-Object Name |        ForEach-Object {
                [pscustomobject]@{
                # Split Name field
                Name  = $_.Name
                Name2 = $_.Name -replace "\.","" -replace "\[","" -replace "\]","" -replace "\-","" -replace "_",""  # Remove illegal characters
                Type  = $_.Value.Gettype().Name
                Type2 = if ($_.Value.Gettype().Name -eq 'Int64') { 'int' }
                        elseif ($_.Value.Gettype().Name -eq 'Int32') { 'int' }
                        elseif ($_.Value.Gettype().Name -eq 'String') { 'string' }
                        elseif ($_.Value.Gettype().Name -eq 'Boolean') { 'bool' }
                } # end pscustomobject
        } # end foreach-object

        foreach ($set in $settings) {
          if ($skip -eq $set.Name) { 
            Write-Verbose "Skip $($set.Name)"
          } else {
            Write-Verbose "Create test for $($set.Name)"

            # Here document, do not indent!
            $formatText = @"
# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
SSSSSTitle = '$($set.Name)'

# Test description: How New-VesterConfig explains this value to the user
SSSSSDescription = 'Test has been auto generated, no description'
# Default value = not available

# The config entry stating the desired values
SSSSSDesired = SSSSScfg.host.$($set.Name2)

# The test value's data type, to help with conversion: bool/string/int
SSSSSType = '$($set.Type2)'

# The command(s) to pull the actual value for comparison
# SSSSSObject will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]SSSSSActual = {
    (Get-AdvancedSetting -Entity SSSSSObject | Where-Object -FilterScript {
        SSSSS_.Name -eq '$($set.Name)'
    }).Value
}

# The command(s) to match the environment to the config
# Use SSSSSObject to help filter, and SSSSSDesired to set the correct value
[ScriptBlock]SSSSSFix = {
    Get-AdvancedSetting -Entity SSSSSObject | Where-Object -FilterScript {
            SSSSS_.Name -eq '$($set.Name)'
        } | Set-AdvancedSetting -Value SSSSSDesired -Confirm:SSSSSfalse -ErrorAction Stop
}
"@
            $formatText > "AS-$($set.Name2).txt"
            (Get-Content -Path "AS-$($set.Name2).txt" -Raw) -replace 'SSSSS','$' > "AS-$($set.Name2).Vester.ps1"
            Remove-Item -Path "AS-$($set.Name2).txt"
          } # end else
        } # end foreach
    } # end process
    End
    {
        Disconnect-VIServer -Server $Server -Force -Confirm:$false
    } # end end
} # end function
