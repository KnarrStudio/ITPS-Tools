function Invoke-AdUserDisable{
  <#
      .SYNOPSIS
      Disables AD User Accounts after the "DaysBack" period of time.

      .PARAMETER DaysBack
      Days back from current Date.  Used to define the oldest date of interest.  Items older will be acted on.

      .EXAMPLE
      Invoke-AdUserDisable -DaysBack VALUE
      This will disable the user's account which has been inactive over the past VALUE days.

      .NOTES
      Place additional notes here.

      .LINK
    
      The first link is opened by Get-Help -Online Invoke-AdUserDisable
  #>

  [CmdletBinding()]
  param(
    [int]$DaysBack = 30
  )
 
  $DateStamp = Get-Date -Format dd/MM/yyyy
 
  $inactiveUsers = Search-ADAccount -AccountInactive -UsersOnly -TimeSpan "$DaysBack.00:00:0"
  $inactiveUsers | Disable-AdUser -Confirm:$False
  foreach($InactiveUser in $inactiveUsers){
    $InactiveUser | Set-aduser -discription ('{0} - Account disable by script' -f $DateStamp)
  } # End - foreach($InactiveUser in $inactiveUsers)
    
} # End - function Invoke-AdUserDisable

function invoke-AdUserDelete{
  <#
      .SYNOPSIS
      Deletes disabled AD User Accounts after the "DaysBack" period of time.
    
      .PARAMETER DaysBack
      Days back from current Date.  Used to define the oldest date of interest.  Items older will be acted on.

      .EXAMPLE
      Invoke-AdUserDelete -DaysBack VALUE
      This will delete the user's account which has been inactive for VALUE1 days and disabled VALUE2 days.

      .NOTES
      Place additional notes here.

      .LINK
    
      The first link is opened by Get-Help -Online Invoke-AdUserDisable
  #>
  
  [CmdletBinding()]
  param(
    [int]$DaysBack = 45,
    [String]$ServerName = 'localhost'
  )
  

  param(
  [Parameter(Mandatory)]$DaysBack
  )
 
  $DisabledUsers = Search-ADAccount -AccountDisabled -UsersOnly -TimeSpan "$DaysBack.00:00:0"
  $DisabledUsers | ForEach-Object {
    if ($PSCmdlet.ShouldProcess($_.Name,'Remove')) {
      $_ | Remove-AdUser -Confirm:$false
    } # End - if($PSCmdlet.ShouldProcess
  }
}

<#  $DisabledUserEvent = Get-WinEvent -ComputerName $ServerName -FilterHashtable @{logname='system';id=6006;StartTime=$DaysBack}
    foreach($DisabledUser in $DisabledUserEvent){
    if(
  
    $DisabledUser.message
    if($DisabledUserEvent.TimeCreated -lt $DaysBack){
    for
  
    }
    
    $DisabledUsers = Search-ADAccount -AccountInactive -UsersOnly -TimeSpan "$DaysBack.00:00:0"
$DisabledUsers | Delete-AdUser -Confirm:$True#>
# End - function invoke-AdUserDelete
