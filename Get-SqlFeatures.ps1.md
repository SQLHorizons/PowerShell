## Function

```powershell

function Get-SqlFeatures {
    #Requires -RunAsAdministrator

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory = $false, DontShow = $true)]
        [ValidateNotNullOrEmpty()]
        [System.DateTime]
        $start = $(Get-Date),
        
        [Parameter(Mandatory = $false, DontShow = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $search = @{
            Recurse     = $true
            Include     = "setup.exe"
            Path        = "$env:ProgramFiles\Microsoft SQL Server"
            ErrorAction = "SilentlyContinue"
        },

        [Parameter(Mandatory = $false, DontShow = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $filter = @{
            InputObject  = $(Get-ChildItem @search)
            FilterScript = {
                $_.FullName -match "Setup Bootstrap\\SQL" -or
                $_.FullName -match "Bootstrap\\Release\\Setup.exe" -or 
                $_.FullName -match "Bootstrap\\Setup.exe"
            }
        }
    )

    Try {

        $setup = $(Where-Object @filter) | Sort-Object FullName | Select-Object -First 1

        if ( [bool] $setup ) {
            $process = @{
                FilePath     = $($setup.FullName)
                ArgumentList = @(
                    "/Action=RunDiscovery"
                    "/q"
                )
                WindowStyle  = "Hidden"
                Wait         = $true
            }
        }
        $null = Start-Process @process

        $GetReport = @{
            Recurse     = $true
            Include     = "SqlDiscoveryReport.xml"
            Path        = $(Split-Path (Split-Path $setup.Fullname))
            ErrorAction = "SilentlyContinue"
        }

        $xmlfile = Get-ChildItem @GetReport | Sort-Object LastWriteTime | Select-Object -First 1

        if ( [bool] $xmlfile ) { 

            $response = foreach ( $result in $($([xml](Get-Content -Path $xmlfile)).ArrayOfDiscoveryInformation.DiscoveryInformation) ) {
                [System.Management.Automation.PSCustomObject]@{           
                    ComputerName      = $env:COMPUTERNAME
                    Product           = $result.Product
                    Instance          = $result.Instance
                    InstanceID        = $result.InstanceID
                    Feature           = $result.Feature
                    Language          = $result.Language
                    Edition           = $result.Edition
                    Version           = $result.Version
                    Clustered         = $result.Clustered
                    Configured        = $result.Configured
                }
            }

        }

        ##  ALL DONE
        
        ##  Write-Log -status $status -message "Script complete"
        $runtime = [Math]::Round(((Get-Date) - $start).TotalMinutes, 2)
        Write-Host "Script complete, total runtime: $("{0:N2}" -f $runtime) minutes."

        Return $response

    }
    Catch [System.Exception] {

        Write-Verbose "Error at line: $(($PSItem[0].InvocationInfo.line).Trim())"
        $PSCmdlet.ThrowTerminatingError($PSItem)

    }
}

```

## Option 1

```powershell

$start = Get-Date
$search = @{
    Recurse     = $true
    Include     = "setup.exe"
    Path        = "$env:ProgramFiles\Microsoft SQL Server"
    ErrorAction = "SilentlyContinue"
}

$filter = @{
    InputObject  = $(Get-ChildItem @search)
    FilterScript = {
        $_.FullName -match "Setup Bootstrap\\SQL" -or
        $_.FullName -match "Bootstrap\\Release\\Setup.exe" -or 
        $_.FullName -match "Bootstrap\\Setup.exe"
    }
}

$setup = $(Where-Object @filter) | Sort-Object FullName | Select-Object -First 1

if ( [bool] $setup ) {
    $process = @{
        FilePath     = $($setup.FullName)
        ArgumentList = @(
            "/Action=RunDiscovery"
            "/q"
        )
        WindowStyle  = "Hidden"
        Wait         = $true
    }
}
$null = Start-Process @process

$GetReport = @{
    Recurse     = $true
    Include     = "SqlDiscoveryReport.xml"
    Path        = $(Split-Path (Split-Path $setup.Fullname))
    ErrorAction = "SilentlyContinue"
}

$xmlfile = Get-ChildItem @GetReport | Sort-Object LastWriteTime | Select-Object -First 1

if ( [bool] $xmlfile ) { 

    foreach ( $result in $($([xml](Get-Content -Path $xmlfile)).ArrayOfDiscoveryInformation.DiscoveryInformation) ) {
        [pscustomobject]@{           
            ComputerName      = $env:COMPUTERNAME
            Product           = $result.Product
            Instance          = $result.Instance
            InstanceID        = $result.InstanceID
            Feature           = $result.Feature
            Language          = $result.Language
            Edition           = $result.Edition
            Version           = $result.Version
            Clustered         = $result.Clustered
            Configured        = $result.Configured
        }
    }

}

##  Write-Log -status $status -message "Script complete"
$runtime = [Math]::Round(((Get-Date) - $start).TotalMinutes, 2)
Write-Host "Script complete, total runtime: $("{0:N2}" -f $runtime) minutes."

```

Results:

```text

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft SQL Server 2017
Instance     : MSSQLSERVER
InstanceID   : MSSQL14.MSSQLSERVER
Feature      : Database Engine Services
Language     : 1033
Edition      : Developer Edition
Version      : 14.0.3294.2
Clustered    : No
Configured   : Yes

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft SQL Server 2017
Instance     : 
InstanceID   : 
Feature      : Integration Services
Language     : 1033
Edition      : Developer Edition
Version      : 14.0.3294.2
Clustered    : No
Configured   : Yes

Script complete, total runtime: 0.09 minutes.

```

## Option 2

- list installed products: `$Products = Get-CimInstance -Class Win32_Product`

```powershell

$start = Get-Date
$CimObjectParameters = @{
    Class        = "Win32_Product"
    Filter       = "Name like '%SQL%' and Vendor = 'Microsoft Corporation'"
    ComputerName = $env:COMPUTERNAME
    ErrorAction  = "Stop"
}

foreach ( $result in $(Get-CimInstance @CimObjectParameters) ) {
    [pscustomobject]@{
        ComputerName      = $result.PSComputerName
        Product           = $result.Name
        Instance          = ""
        InstanceID        = ""
        Feature           = $result.Feature
        Language          = ""
        Edition           = ""
        Version           = $result.Version
        Clustered         = ""
        Configured        = ""
    }
}

##  Write-Log -status $status -message "Script complete"
$runtime = [Math]::Round(((Get-Date) - $start).TotalMinutes, 2)
Write-Host "Script complete, total runtime: $("{0:N2}" -f $runtime) minutes."

```

Results:

```test

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Database Engine Shared
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Integration Services
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

Script complete, total runtime: 3.71 minutes.

```

## Reference

- [Get-DbaSqlFeature](https://www.powershellgallery.com/packages/dbatools/0.9.332/Content/functions%5CGet-DbaSqlFeature.ps1)
