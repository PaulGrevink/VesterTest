function New-VesterDashboard {
	<#
	.SYNOPSIS
        This function runs the Invoke-Vester command on one or more vombinations of a vCenter
        Server and a Vester Configuration file and creates a Dashboard
        This version expects the in put in the form of 3 arrays:
        [Array]Labels contains an unique label
        [Array]VCs contains the FQDN or IP address of a vCenter Server
        [Array]Configs contains the path to the Vester Config file
        Vester config files must be created using New-VesterConfig

	.EXAMPLE
		PS> New-Vester Dashboard
        This example creates a new dahboard.
        Open a browser and add URL: http://localhost:10000

    .EXAMPLE
        To stop a dahboard run the following command
        PS> Get-UDDashboard -Name 'VesterDashboard' | Stop-UDDashboard
	#>

	[CmdletBinding()]
	Param (
        [parameter(Mandatory=$true)]
        [string[]]$Labels,
        [parameter(Mandatory=$true)]
        [string[]]$VCs,
        [parameter(Mandatory=$true)]
        [string[]]$Configs,
        [parameter(Mandatory=$true)]
        [string[]]$Descriptions,
        [parameter(Mandatory=$true)]
        $TestScopes
        )

    #
    [Array]$ConnectionStatus = @()
    [Array]$Vesters = @()
    [Array]$DateTimes = @()
    [Array]$VCColors = @()
    [Array]$GridDatas = @()
    [Array]$Pages = @()
    #
    # Test Config files
    $ConfigNOK = $False
    foreach ($Config in $Configs) {
        if (!(Test-Path $Config -PathType leaf)) {
            Write-Host "Configuration file is missing: " $Config
            $ConfigNOK = $True
        }
    }
    if ($ConfigNOK) { exit }
    #
    $i = 0
    foreach ($Label in $Labels) {
        # Run Invoke-Vester
        if (!$creds) {$creds = Get-Credential "administrator@vsphere.local"}

        if (!(Connect-VIServer -Server $VCs[$i] -Credential $creds -ErrorAction SilentlyContinue)) {
            Write-Host "vCenter Server not reachable: " $VCs[$i]
            $ConnectionStatus += $false
            $Vesters += , $false
            $DateTimes += Get-Date
            $VCColor = 'red'
            $VCColors += $VCColor
            $GridDatas += , $false
        } else {
            $ConnectionStatus += $true
            # Cis
            Connect-CisServer -Server $VCs[$i] -Credential $creds
            $Vester = Invoke-Vester -Config $Configs[$i] -Test (Get-VesterTest -Scope $TestScopes[$i]) -PassThru
            $Vesters += , $Vester
            $DateTimes += Get-Date
            Disconnect-VIServer -Server $VCs[$i] -Force -Confirm:$false
            Disconnect-CisServer -Server $VCs[$i] -Force -Confirm:$false
            #
            # Process Data
            if ($Vester.FailedCount -ne 0) { $VCColor = 'yellow' }
            if ($Vester.FailedCount -eq 0) { $VCColor = 'green' }
            $VCColors += $VCColor
            # Create DataGrid
            $GridData = $Vester.TestResult | Where-Object {$_.Passed -eq $false} |
            ForEach-Object {
                [pscustomobject]@{
                # Split Name field
                VC        = $VCs[$i]
                Scope     = $_.Name.Split(" ")[0]
                Name      = $_.Name.Split(" ")[1]
                TestTitle = $_.Name.Split("-")[-1].Substring(1)
                # Convert Errorcode to String, Split on linebreak and remove first part
                Desired   = $_.ErrorRecord.ToString().Split([Environment]::NewLine)[0].Substring(11)
                Actual    = $_.ErrorRecord.ToString().Split([Environment]::NewLine)[1].Substring(11)
                Synopsis  = $_.ErrorRecord.ToString().Split([Environment]::NewLine)[2].Substring(11)
                Vtest    = ($_.ErrorRecord.ToString().Split([Environment]::NewLine)[4].Split("\")[-1]).Split(".")[0] # Must match testfile except ".Vester.ps1"
                Fixed     = "N"
                }
            }
            $GridDatas += , $GridData
        }
        $i++
    }

    # Create New Dashboard
    $FontColor = 'Black'
    # Index
    $i = 0
    $HomePage = New-UDPage -Name "Home" -Icon home -DefaultHomePage -Content {
        New-UDRow {
            New-UDColumn -Size 12 {
              New-UDLayout -Columns 3 -Content {
                foreach ($Label in $Labels) {
                    New-UDCard -Title $VCs[$i] -Content {
                    if ($ConnectionStatus[$i]) {
                      New-UDParagraph -Text "Label : $($Labels[$i])"  -Color $FontColor
                      New-UDParagraph -Text "Config: $($Configs[$i])" -Color $FontColor
                      New-UDParagraph -Text "Desc. : $($Descriptions[$i])" -Color $FontColor
                      New-UDParagraph -Text "=== Test Results of $($DateTimes[$i]) ==="  -Color $FontColor
                      New-UDParagraph -Text "Total   : $($Vesters[$i].TotalCount)"    -Color 'Black'
                      New-UDParagraph -Text "Passed  : $($Vesters[$i].PassedCount)"   -Color 'Black'
                      New-UDParagraph -Text "Failed  : $($Vesters[$i].FailedCount)"   -Color 'Red'
                      New-UDParagraph -Text "Skipped : $($Vesters[$i].SkippedCount)"  -Color 'Black'
                      New-UDParagraph -Text "Pending : $($Vesters[$i].PendingCount)"  -Color 'Black'
                      } else {
                      New-UDParagraph -Text "Label : $($Labels[$i])"  -Color $FontColor
                      New-UDParagraph -Text "Config: $($Configs[$i])" -Color $FontColor
                      New-UDParagraph -Text "Desc. : $($Descriptions[$i])" -Color $FontColor
                      New-UDParagraph -Text "=== Connection Failed at $($DateTimes[$i]) ==="  -Color $FontColor
                      New-UDParagraph -Text "."    -Color $FontColor
                      New-UDParagraph -Text "."    -Color $FontColor
                      New-UDParagraph -Text "."    -Color $FontColor
                      New-UDParagraph -Text "."    -Color $FontColor
                      New-UDParagraph -Text "."    -Color $FontColor
                      }
                    } -FontColor $FontColor -BackgroundColor $VCColors[$i] -Links @(
                        New-UDLink -Text "See Errors" -Url "ERR_$($Labels[$i].ToString())" -Icon book
                        New-UDLink -Text "See Config" -Url "CFG_$($Labels[$i].ToString())" -Icon book
                        )
                    $i ++
                }
              }
            }
          }
    } -AutoRefresh -RefreshInterval 20
    $Pages += , $HomePage

    # Error pages
    # Index
    $i = 0
    foreach ($Label in $Labels) {
        $Page = New-UDPage -Name "ERR_$($Labels[$i].ToString())" -Icon grav -Content {
            if($ConnectionStatus[$i]) {
                New-UDRow {
                    New-UDColumn -Size 12 {
                        New-UDGrid -Title "Errors $($VCs[$i])" -Headers @("Scope", "Name", "Test", "Desired", "Actual", "Synopsis") -Properties @("Scope", "Name", "TestTitle", "Desired", "Actual", "Synopsis") -Endpoint {
                            $ArgumentList[0][$ArgumentList[1]] | ForEach-Object {
                                [PSCustomObject]@{
                                Scope     = $_.Scope
                                Name      = $_.Name
                                TestTitle = $_.TestTitle
                                Desired   = $_.Desired
                                Actual    = $_.Actual
                                Synopsis  = $_.Synopsis
                                }
                            } | Out-UDGridData
                        } -ArgumentList $GridDatas, $i -FontColor "black"  # -AutoRefresh -RefreshInterval 5
                    }
                }
            }
        }
        $Pages += , $Page
        $i ++
    }

    # Config pages
    $i = 0
    foreach ($Label in $Labels) {
        $Page = New-UDPage -Name "CFG_$($Labels[$i].ToString())" -Icon grav -Content {
            $MyConfig = (Get-Content -path $Configs[$i]).replace(' ', '.')
            New-UDCard -Title "Config file $($VCs[$i])" -Content {
                foreach ($line in $MyConfig) {
                    New-UDParagraph -text $line -Color "Blue"
                }
            } -FontColor "black"
        }
        $Pages += , $Page
        $i ++
    }

    # Stop old dashboard
    Get-UDDashboard -Name 'VesterDashboardIPC' | Stop-UDDashboard

    #Start presenting Dashboard
    $MyInit = New-UDEndpointInitialization -Variable @("Labels", "VCs", "Configs", "Creds") -Function @("New-VesterDashboard") -Module @("Vester", "Pester", "VMware.VimAutomation.Core")
    Start-UDDashboard -Content {
        New-UDDashboard -Title "Vester IPC Dashboard" -Pages $Pages -EndpointInitialization $MyInit -NavBarColor 'Orange' -NavBarFontColor 'Ẃhite' -BackgroundColor "#FF333333" -FontColor "#FFFFFFF"
    } -Port 10000 -Name 'VesterDashboardIPC' # -AutoReload
} # eof function

# Main

# Labels MUST be unique values

$Labels = @("VC_A",
            "VC_B")
$VCs = @("vcA.virtual.local",
         "vcB.virtual.local")
$Configs = @("C:\Program Files\WindowsPowerShell\Modules\Vester\1.2.0\Configs\ConfigA.json",
             "C:\Program Files\WindowsPowerShell\Modules\Vester\1.2.0\Configs\ConfigB.json")
$Descriptions = @("Description VC_A",
                  "Description VC_B")

[Array[]]$TestScopes =@(('vCenter'),
                        ('vCenter','Host'),
                        ('')) # Always end with this empty line

# End of Variables

if (!$creds) {$creds = Get-Credential -User 'administrator@vsphere.local' -Message 'Password Please' }

# For a single run, uncomment the next line
New-VesterDashboard $Labels $VCs $Configs $Descriptions $TestScopes

# For a continuous update of the dashboard, uncomment the while loop
<#
while ($true) {
    New-VesterDashboard $Labels $VCs $Configs $Descriptions $TestScopes
    Write-Host "Loop finished..."
    Start-Sleep 7200 # 2uur
}
#>