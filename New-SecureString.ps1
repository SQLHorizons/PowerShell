function New-SecureString {
    [CmdletBinding()]
    [OutputType([PSCredential])]
    param (
        [Parameter(DontShow = $true)]
        [System.String]
        $InputObject
    )

    Process {
        Try {
            $guid = (New-Guid).Guid
            $SecureString = [System.Security.SecureString]::New()
            foreach ( $char in $($guid[0..$guid.Length]) ) {
                $SecureString.AppendChar($char)
            }

            ##  ALL DONE
            Return [PSCredential]::New( "token", $SecureString )
        }
        Catch [System.Exception] {
            Write-Verbose "Error at line: $(($PSItem[0].InvocationInfo.line).Trim())"
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
