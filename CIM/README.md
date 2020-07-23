# Cim

## NumberOfLogicalProcessors (Wmi)

```powershell
$this = @{
   ServerName = $env:COMPUTERNAME
}

$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
}

Write-Host "Getting the number of files based on processor count."
$this["Files"] = (Get-WmiObject @Parameters).NumberOfLogicalProcessors;
if ($this.Files -gt 8) {$this.Files = 8};
$this.Files
```
## NumberOfLogicalProcessors (Cim)

```powershell
$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
}

Write-Verbose "Getting the number of files based on processor count."
$this.Files = (Get-WmiObject @Parameters).NumberOfLogicalProcessors;
if ($this.Files -gt 8) {$this.Files = 8};
```
