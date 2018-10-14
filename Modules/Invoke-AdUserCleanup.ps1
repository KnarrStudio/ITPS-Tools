function Invoke-AdUserCleanup {
    [CmdletBinding()]
    param($OlderThan)
 
    $inactiveUsers = Search-ADAccount -AccountInactive -UsersOnly -TimeSpan "$OlderThan.00:00:0"
    $inactiveUsers | Disable-AdUser -Confirm:$True
}