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
