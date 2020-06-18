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
Product      : SQL Server 2017 Shared Management Objects Extensions
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Common Files
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Batch Parser
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft ODBC Driver 13 for SQL Server
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.3294.2
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Shared Management Objects Extensions
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 DMF
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft System CLR Types for SQL Server 2019 CTP3.0
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 15.0.1600.8
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Shared Management Objects
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

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
Product      : SQL Server 2017 Connection Info
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 SQL Diagnostics
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Browser for SQL Server 2017
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft SQL Server 2017 Setup (English)
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.3294.2
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

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Common Files
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft SQL Server 2017 T-SQL Language Service 
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.3294.2
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft VSS Writer for SQL Server 2017
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Shared Management Objects
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Database Engine Services
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Database Engine Services
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 XEvent
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Active Directory Authentication Library for SQL Server
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.3015.40
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 XEvent
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

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

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 SQL Data Quality Common
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 Connection Info
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft SQL Server 2017 RsFx Driver
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.3294.2
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : SQL Server 2017 DMF
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 14.0.1000.169
Clustered    : 
Configured   : 

ComputerName : EC2AMAZ-LBRL2P3
Product      : Microsoft SQL Server 2012 Native Client 
Instance     : 
InstanceID   : 
Feature      : 
Language     : 
Edition      : 
Version      : 11.3.6540.0
Clustered    : 
Configured   : 

Script complete, total runtime: 3.71 minutes.

```
