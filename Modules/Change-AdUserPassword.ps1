#Requires -RunAsAdministrator
#Requires -Module ActiveDirectory

$LockedOutAccountBoxColor = 'Yellow'
$LockedOutAccountBox = '------- Locked Out Accounts -----------'

$DefaultPassword = '1qaz@WSX3edc!QAZ'

Write-Host $LockedOutAccountBox -ForegroundColor $LockedOutAccountBoxColor 
Search-AdAccount -Lockedout
Write-Host $LockedOutAccountBox -ForegroundColor $LockedOutAccountBoxColor 

$AdUserAccountNeededPwdReset = Read-Host -Prompt 'Enter username of account to be reset to Default'
Set-ADAccountPassword -Identity $AdUserAccountNeededPwdReset -Reset -NewPassword (ConvertTo-SecureString -AsPlainText -String $DefaultPassword -Force)

