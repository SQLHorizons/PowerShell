# SecureString

```powershell
$guid = (New-Guid).Guid
$SecureString = [System.Security.SecureString]::New()
foreach ( $char in $($guid[0..$guid.Length]) ) {
    $SecureString.AppendChar($char)
}
Return $([PSCredential]::New( "token", $SecureString )).GetNetworkCredential().Password

$guid = (New-Guid).Guid
$SecureString = [System.Security.SecureString]::New()
$guid[0..$guid.Length] | ForEach-Object {
    $SecureString.AppendChar($_)
}
Return $([PSCredential]::New( "token", $SecureString )).GetNetworkCredential().Password
```
