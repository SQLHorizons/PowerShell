# Cim

## NumberOfLogicalProcessors

```powershell
$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
    ErrorAction  = "Stop"
}

Write-Verbose "Getting the number of files based on processor count."
$this.Files = (Get-WmiObject @Parameters).NumberOfLogicalProcessors;
if ($this.Files -gt 8) {$this.Files = 8};
```

```powershell
$Parameters = @{
    ComputerName = $this.ServerName
    Class        = "Win32_ComputerSystem"
    ErrorAction  = "Stop"
}

Write-Verbose "Getting the number of files based on processor count."
$this.Files = (Get-WmiObject @Parameters).NumberOfLogicalProcessors;
if ($this.Files -gt 8) {$this.Files = 8};
```
