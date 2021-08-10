#Requires -RunAsAdministrator

#import the Active Directory module if not already up and loaded
$module = Get-Module | Where-Object {$_.Name -eq 'ActiveDirectory'}
if ($module -eq $null) {
		Write-Host "Loading Active Directory PowerShell Module"
		Import-Module ActiveDirectory -ErrorAction SilentlyContinue
	}
	
$LockedOutAccountBoxColor = 'Yellow'
$LockedOutAccountBox = '------- Locked Out Accounts -----------'

$DefaultPassword = '1qaz@WSX3edc!QAZ'

Write-Host $LockedOutAccountBox -ForegroundColor $LockedOutAccountBoxColor 
Search-AdAccount -Lockedout
Write-Host $LockedOutAccountBox -ForegroundColor $LockedOutAccountBoxColor 

$AdUserAccountNeededPwdReset = Read-Host -Prompt 'Enter username of account to be reset to Default'
Set-ADAccountPassword -Identity $AdUserAccountNeededPwdReset -Reset -NewPassword (ConvertTo-SecureString -AsPlainText -String $DefaultPassword -Force)

