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

    if ($invokeCimMethodResult -and $invokeCimMethodResult.HRESULT -ne 0) {
        if ($invokeCimMethodResult | Get-Member -Name "ExtendedErrors") {
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
