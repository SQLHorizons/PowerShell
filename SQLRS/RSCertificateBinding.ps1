﻿function Set-SSLCertificateBinding {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([System.Int32])]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate = $((Get-ChildItem "cert:\LocalMachine\root").Where{ $_.Subject -eq "CN=$env:COMPUTERNAME" }),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $endpoint = $($env:endpoint)
    )

    Try {

        if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {

            $CertificateBindingParameters = @{
                CimInstance = $(Get-ReportingServicesData SSRS).Configuration
                MethodName  = "CreateSSLCertificateBinding"
                Arguments   = @{
                    CertificateHash = [String]$Certificate.GetCertHashString().ToLower()
                    IPAddress       = [String]"0.0.0.0"
                    Port            = [Int32]443
                    Lcid            = [Int32]$(Get-Culture).LCID
                }
            }

            $ReserveURLParameters = @{
                CimInstance = $(Get-ReportingServicesData SSRS).Configuration
                MethodName  = "ReserveURL"
                Arguments   = @{
                    UrlString       = [String]"https://$($endpoint):443"
                    Lcid            = [Int32]$(Get-Culture).LCID
                }
            }

            foreach ( $Application in @("ReportServerWebService","ReportServerWebApp") ) {
                $CertificateBindingParameters.Arguments["Application"] = [String]$Application
                $ReserveURLParameters.Arguments["Application"] = [String]$Application
                $null = Invoke-RsCimMethod @CertificateBindingParameters
                $null = Invoke-RsCimMethod @ReserveURLParameters
            }

            Restart-Service SQLServerReportingServices -Force

        }

        ##  ALL DONE
        Write-Verbose "ALL DONE"

        Return 0

    }
    Catch [System.Exception] {
        Write-Verbose "Error at line: $(($PSItem[0].InvocationInfo.line).Trim())"
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}

function Get-ReportingServicesData {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $instanceNamesRegistryKey = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS"

    if (Get-ItemProperty -Path $instanceNamesRegistryKey -Name $InstanceName -ErrorAction SilentlyContinue) {
        $instanceId = (Get-ItemProperty -Path $instanceNamesRegistryKey -Name $InstanceName).$InstanceName

        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\MSSQLServer\CurrentVersion") {
            # SQL Server 2017 SSRS stores current SQL Server version to a different Registry path.
            $sqlVersion = [int]((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$InstanceId\MSSQLServer\CurrentVersion" -Name "CurrentVersion").CurrentVersion).Split(".")[0]
        }
        else {
            $sqlVersion = [int]((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\Setup" -Name "Version").Version).Split(".")[0]
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
            $reportsApplicationName = "ReportServerWebApp"
        }
        else {
            $reportsApplicationName = "ReportManager"
        }
    }

    Return @{
        Configuration          = $reportingServicesConfiguration
        ReportsApplicationName = $reportsApplicationName
        SqlVersion             = $sqlVersion
    }
}

function Invoke-RsCimMethod {
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimMethodResult])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]
        $CimInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MethodName,

        [Parameter()]
        [System.Collections.Hashtable]
        $Arguments
    )

    $invokeCimMethodParameters = @{
        MethodName  = $MethodName
        ErrorAction = "Stop"
    }

    if ($PSBoundParameters.ContainsKey("Arguments")) {
        $invokeCimMethodParameters["Arguments"] = $Arguments
    }

    $invokeCimMethodResult = $CimInstance | Invoke-CimMethod @invokeCimMethodParameters

    if ($invokeCimMethodResult -and $invokeCimMethodResult.HRESULT -ne 0) {
        if ($invokeCimMethodResult | Get-Member -Name "ExtendedErrors") {
            $errorMessage = $invokeCimMethodResult.ExtendedErrors -join ";"
        }
        else {
            $errorMessage = $invokeCimMethodResult.Error
        }

        Throw "Method {0}() failed with an error. Error: {1} (HRESULT:{2})" -f @(
            $MethodName
            $errorMessage
            $invokeCimMethodResult.HRESULT
        )
    }

    Return $invokeCimMethodResult

}
