# [Get-CimInstance](https://docs.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance)

Gets the CIM instances of a class from a CIM server.

## References

- [Get-CIMInstance Vs Get-WMIObject](https://blog.ipswitch.com/get-ciminstance-vs-get-wmiobject-whats-the-difference)

## Get-WmiObject Example

```powershell

$WmiObjectParameters = @{
    Namespace    = "root\Microsoft\SqlServer\ReportServer"
    Class        = "__Namespace"
    ComputerName = $env:COMPUTERNAME
    ErrorAction  = "Stop"
}
$ReportServerInstance = (Get-WmiObject @WmiObjectParameters).Name

```
