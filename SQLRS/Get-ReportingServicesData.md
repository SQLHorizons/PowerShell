# Get-ReportingServicesData

Notes

## Function:

```powershell
function Get-ReportingServicesData {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $instanceNamesRegistryKey = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS'

    if (Get-ItemProperty -Path $instanceNamesRegistryKey -Name $InstanceName -ErrorAction SilentlyContinue) {
        $instanceId = (Get-ItemProperty -Path $instanceNamesRegistryKey -Name $InstanceName).$InstanceName

        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\MSSQLServer\CurrentVersion") {
            # SQL Server 2017 SSRS stores current SQL Server version to a different Registry path.
            $sqlVersion = [int]((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$InstanceId\MSSQLServer\CurrentVersion" -Name 'CurrentVersion').CurrentVersion).Split('.')[0]
        }
        else {
            $sqlVersion = [int]((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\Setup" -Name 'Version').Version).Split('.')[0]
        }

        $reportingServicesConfiguration = Get-CimInstance -ClassName MSReportServer_ConfigurationSetting -Namespace "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$sqlVersion\Admin"
        $reportingServicesConfiguration = $reportingServicesConfiguration | Where-Object -FilterScript {
            $_.InstanceName -eq $InstanceName
        }

        <#
            SQL Server Reporting Services Web Portal application name changed
            in SQL Server 2016.
            https://docs.microsoft.com/en-us/sql/reporting-services/breaking-changes-in-sql-server-reporting-services-in-sql-server-2016
        #>
        if ($sqlVersion -ge 13) {
            $reportsApplicationName = 'ReportServerWebApp'
        }
        else {
            $reportsApplicationName = 'ReportManager'
        }
    }

    @{
        Configuration          = $reportingServicesConfiguration
        ReportsApplicationName = $reportsApplicationName
        SqlVersion             = $sqlVersion
    }
}
<#
    .SYNOPSIS
        Returns SQL Reporting Services data: configuration object used to initialize and configure
        SQL Reporting Services and the name of the Reports Web application name (changed in SQL 2016)
    .PARAMETER InstanceName
        Name of the SQL Server Reporting Services instance for which the data is being retrieved.
#>
```
