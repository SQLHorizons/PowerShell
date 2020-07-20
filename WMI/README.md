WMI Providers

```powershell
$wmiNS = "root\cimV2"
Get-WmiObject -class __Provider -namespace $wmiNS|Sort-Object -property Name|Format-List Name
```
