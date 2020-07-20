# [Get-CimInstance](https://docs.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance)

Gets the CIM instances of a class from a CIM server.

## References

- [Get-CIMInstance Vs Get-WMIObject](https://blog.ipswitch.com/get-ciminstance-vs-get-wmiobject-whats-the-difference)

## [Get-WmiObject](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject) Example

```powershell

$WmiObjectParameters = @{
    Namespace    = "root"
    Class        = "__Namespace"
    ComputerName = $env:COMPUTERNAME
    ErrorAction  = "Stop"
}
Get-WmiObject @WmiObjectParameters

```

- list installed products: `Get-WmiObject -Class Win32_Product`

## Get-CimInstance Example

```powershell

$CimObjectParameters = @{
    Namespace    = "root"
    Class        = "__Namespace"
    ComputerName = $env:COMPUTERNAME
    ErrorAction  = "Stop"
}
Get-CimInstance @CimObjectParameters

```

- list installed products: `$Products = Get-CimInstance -Class Win32_Product`

## Get MSReportServer ConfigurationSetting Class

```powershell
$GetCimInstanceParameters = @{
    ClassName = "MSReportServer_ConfigurationSetting"
    Namespace = "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$sqlVersion\Admin"
}
$reportingServicesConfiguration = Get-CimInstance $GetCimInstanceParameters
```


```powershell
$GetCimInstanceParameters = @{
    ClassName = "SqlServiceAdvancedProperty"
    Namespace = "root\Microsoft\SqlServer\ComputerManagement14"
}
Get-CimInstance $GetCimInstanceParameters
```


Get-WmiObject -Namespace root\Microsoft\SqlServer\ComputerManagement10 `
 -Class SqlServiceAdvancedProperty | 
 Where-Object {$_.PropertyName -eq 'VERSION'} | 
 Format-Table ServiceName, PropertyName, PropertyStrValue -AutoSize

