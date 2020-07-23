# Cim

## NumberOfLogicalProcessors (Wmi)

```powershell
$this = @{ ServerName = $env:COMPUTERNAME }

<#CODE#>

$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
    ErrorAction  = "Stop"
}

Write-Host "Getting the number of files based on processor count."
$this["Files"] = (Get-WmiObject @Parameters).NumberOfLogicalProcessors;
if ($this.Files -gt 8) {$this.Files = 8};

<#CODE#>

$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
    ErrorAction  = "Stop"
}

Return $this.Files
```
## NumberOfLogicalProcessors (Cim)

```powershell
$this = @{ ServerName = $env:COMPUTERNAME }

<#CODE#>

$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
    ErrorAction  = "Stop"
}

Write-Host "Getting the number of files based on processor count."
$this["Files"] = (Get-CimInstance @Parameters).NumberOfLogicalProcessors;
if ($this.Files -gt 8) {$this.Files = 8};

<#CODE#>

Return $this.Files
```
