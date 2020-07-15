# Invoke-RsCimMethod

Notes

## Reference:

- [[Microsoft.Management.Infrastructure.CimInstance]](https://docs.microsoft.com/en-us/dotnet/api/microsoft.management.infrastructure.ciminstance)

## function

```powershell
function Invoke-RsCimMethod {
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimMethodResult])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]
        $CimInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MethodName,

        [Parameter()]
        [System.Collections.Hashtable]
        $Arguments
    )

    $invokeCimMethodParameters = @{
        MethodName  = $MethodName
        ErrorAction = "Stop"
    }

    if ($PSBoundParameters.ContainsKey("Arguments")) {
        $invokeCimMethodParameters["Arguments"] = $Arguments
    }

    $invokeCimMethodResult = $CimInstance | Invoke-CimMethod @invokeCimMethodParameters
    <#
        Successfully calling the method returns $invokeCimMethodResult.HRESULT -eq 0.
        If an general error occur in the Invoke-CimMethod, like calling a method
        that does not exist, returns $null in $invokeCimMethodResult.
    #>
    if ($invokeCimMethodResult -and $invokeCimMethodResult.HRESULT -ne 0) {
        if ($invokeCimMethodResult | Get-Member -Name "ExtendedErrors") {
            <#
                The returned object property ExtendedErrors is an array
                so that needs to be concatenated.
            #>
            $errorMessage = $invokeCimMethodResult.ExtendedErrors -join ";"
        }
        else {
            $errorMessage = $invokeCimMethodResult.Error
        }

        Throw "Method {0}() failed with an error. Error: {1} (HRESULT:{2})" -f @(
            $MethodName
            $errorMessage
            $invokeCimMethodResult.HRESULT
        )
    }

    Return $invokeCimMethodResult

}
```
