function New-VesterVcenterAdvanced {
    <#
    .SYNOPSIS
       Create Vester Test files for Advanced Settings of a vCenter Server.

    .DESCRIPTION
       Script generates a set of Vester Test files for all available
       advanced settings of a vCenter Server.
       As all advanced settings can be read and changed with the
       Get-AdvancedSetting and Set-AdvancedSetting cmdlets, scripts can 
       be generated using a here document and some replacements.

    .SYNTAX
       New-VesterVcenterAdvanced [[-Server] <Object>] [<CommonParameters>]

    .EXAMPLE
       PS C:\> New-VesterVcenterAdvanced -Server vc06.virtual.local
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
            # Skip these parameters, seperate with commas
            $skip = @('DBProc.Log.Level.Stats.Purge1',
                      'DBProc.Log.Level.Stats.Purge2'
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
        $Settings = Get-AdvancedSetting -Entity $Server | Sort-Object Name |        ForEach-Object {
                [pscustomobject]@{
                # Split Name field
                Name  = $_.Name
                Name2 = $_.Name -replace "\.","" -replace "\[","" -replace "\]","" -replace "\-","" -replace "_","" -replace ":","" -replace " ","" -replace"\/",""  # Remove illegal characters
                Description = $_.Description
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
SSSSSDescription = '$($set.Description)'
# Default value = not available

# The config entry stating the desired values
SSSSSDesired = SSSSScfg.vcenter.$($set.Name2)

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
            $formatText > "VCAS-$($set.Name2).txt"
            (Get-Content -Path "VCAS-$($set.Name2).txt" -Raw) -replace 'SSSSS','$' > "VCAS-$($set.Name2).Vester.ps1"
            Remove-Item -Path "VCAS-$($set.Name2).txt"
          } # end else
        } # end foreach
    } # end process
    End
    {
        Disconnect-VIServer -Server $Server -Force -Confirm:$false
    } # end end
} # end function
