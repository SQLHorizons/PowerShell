## Notes

```powershell

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
    $xml = [xml](Get-Content -Path $xmlfile)
    Return $xml.ArrayOfDiscoveryInformation.DiscoveryInformation
}

```
