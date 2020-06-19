# Using Cim

## Create CimSession

```powershell
#Requires -Version 5.0

[CmdletBinding()]
param(
    [PSCredential]
    $Credential = $(Get-Credential -UserName "paul.dmax@outlook.com" -Message "Enter Password"),

    [System.Object]
    $CimSessionParams = @{
        ComputerName = "PHOENIX"
        Credential   = $Credential
    }
)

$CimSession = New-CimSession @CimSessionParams

```
