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

## Notes

```powershell

    $setup = Get-ChildItem -Recurse -Include setup.exe -Path "$env:ProgramFiles\Microsoft SQL Server" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match 'Setup Bootstrap\\SQL' -or $_.FullName -match 'Bootstrap\\Release\\Setup.exe' -or $_.FullName -match 'Bootstrap\\Setup.exe' } |
            Sort-Object FullName -Descending | Select-Object -First 1
            
```

