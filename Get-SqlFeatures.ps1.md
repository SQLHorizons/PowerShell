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

$setup = $(Where-Object @filter) | Sort-Object FullName -Descending | Select-Object -First 1

if ( [bool] $setup ) {
    $process = @{
        FilePath     = $($setup.FullName)
        ArgumentList = @(
            "/Action=RunDiscovery"
            "/q"
        )
        Wait         = $true
    }
}
$null = Start-Process @process

$parent = Split-Path (Split-Path $setup.Fullname)
$xmlfile = Get-ChildItem -Recurse -Include SqlDiscoveryReport.xml -Path $parent | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            
            
```
