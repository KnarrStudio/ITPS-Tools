
#import the Active Directory module if not already up and loaded
$module = Get-Module | Where-Object {$_.Name -eq 'ActiveDirectory'}
if ($module -eq $null) {
   Write-Verbose -Message 'Loading Active Directory PowerShell Module'
   Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue
}
function script:Invoke-AdUserDisable
{
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
   $inactiveUsers = Search-ADAccount -AccountInactive -UsersOnly -TimeSpan ('{0}.00:00:0' -f $DaysBack)
   $inactiveUsers | Disable-AdUser -Confirm:$False
   foreach($InactiveUser in $inactiveUsers){
      $InactiveUser | Set-aduser -discription ('{0} - Account disable by script' -f $DateStamp)
   } # End - foreach($InactiveUser in $inactiveUsers)
} # End - function Invoke-AdUserDisable
function script:Remove-ADUserGroups
{
   <#
         .SYNOPSIS
         Removes disabled ueser from groups

         .PARAMETER employeeSAN
         SamAccountName.

         .PARAMETER adServer
         Domain Controller.

         .EXAMPLE
         Remove-ADUserGroups -employeeSAN Value -adServer Value
         Removes AD User from all group membership except for 'Domain Users'

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
   #>
   [CmdletBinding()]
   param
   (
      [string]$employeeSAN = $null,
      [string]$adServer = 'adserver.yourcompany.com'
   )
   try{
      Get-ADUser -Identity $employeeSAN -Server $adServer
      #if that doesn't throw you to the catch this person exists. So you can continue

      $ADgroups = Get-ADPrincipalGroupMembership -Identity $employeeSAN | Where-Object {$_.Name -ne 'Domain Users'}
      if ($ADgroups -ne $null){
         Remove-ADPrincipalGroupMembership -Identity $employeeSAN -MemberOf $ADgroups -Server $adServer -Confirm:$false
      }
   }#end try
   catch{
      Write-verbose -Message ('{0} is not in AD' -f $employeeSAN)
   }
}
function script:invoke-AdUserDelete
{
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
   $DisabledUsers = Search-ADAccount -AccountDisabled -UsersOnly -TimeSpan ('{0}.00:00:0' -f $DaysBack)
   foreach($DisabledUser in $DisabledUsers)
   {
      if ($PSCmdlet.ShouldProcess($DisabledUser.Name,'Remove')) 
      {
         $DisabledUser | Remove-AdUser -Confirm:$false
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


Invoke-AdUserDisable
Remove-ADUserGroups
invoke-AdUserDelete



# SIG # Begin signature block
# MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZWhMPwcYqKfMmCcQWpvRtSE+
# bIqgggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
# MBYxFDASBgNVBAMTC0VyaWtBcm5lc2VuMB4XDTE3MTIyOTA1MDU1NVoXDTM5MTIz
# MTIzNTk1OVowFjEUMBIGA1UEAxMLRXJpa0FybmVzZW4wgZ8wDQYJKoZIhvcNAQEB
# BQADgY0AMIGJAoGBAKYEBA0nxXibNWtrLb8GZ/mDFF6I7tG4am2hs2Z7NHYcJPwY
# CxCw5v9xTbCiiVcPvpBl7Vr4I2eR/ZF5GN88XzJNAeELbJHJdfcCvhgNLK/F4DFp
# kvf2qUb6l/ayLvpBBg6lcFskhKG1vbEz+uNrg4se8pxecJ24Ln3IrxfR2o+BAgMB
# AAGjYDBeMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEcGA1UdAQRAMD6AEMry1NzZravR
# UsYVhyFVVoyhGDAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlboIQyWSKL3Rtw7JMh5kR
# I2JlijAJBgUrDgMCHQUAA4GBAF9beeNarhSMJBRL5idYsFZCvMNeLpr3n9fjauAC
# CDB6C+V3PQOvHXXxUqYmzZpkOPpu38TCZvBuBUchvqKRmhKARANLQt0gKBo8nf4b
# OXpOjdXnLeI2t8SSFRltmhw8TiZEpZR1lCq9123A3LDFN94g7I7DYxY1Kp5FCBds
# fJ/uMYIBSjCCAUYCAQEwKjAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlbgIQyWSKL3Rt
# w7JMh5kRI2JlijAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUVSKpd9qZFZxI3ACoFQxT9H6eE5ow
# DQYJKoZIhvcNAQEBBQAEgYAK2WKzUab6p1HNKkB0w9CW40wy2G1H3U52Y3zA0l3x
# 46AKgWI4tJuq6zu7SSC7ivbfMRVWa0TqFPheItfTjh/Lgu7ft5rspGNEI6yLuLuV
# UGRIV3D2aQOuPceJ7FAHqXah4pq+/HAu+xZwBacwnZ6AJOdVWu9uhmloRx/GVdYj
# xA==
# SIG # End signature block
