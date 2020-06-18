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
