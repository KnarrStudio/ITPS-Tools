
<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   This scripts does the following:
- Removes and/or Creates copies (COOPs) of our servers for quick replacement in the case of a server problem
- This could be modified to create the COOP on the SAN, but this is designed to move the files from the SAN to the local ESXi03(6) datastore.
- Reads in server names from the file: COOP-serverlist.csv (This should be in the same dir as this script)
    - Side Note: Future plans will be to remove the list and COOP servers based on tests.  You may see some of the "pre" work already.
- Copies COOP to: ESXi06-LOCALdatastore02
- Write to Host: 214.18.207.89

.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
.NOTE
Script Name: COOPVMs.ps1
Author Name: Erik Arnesen
Version : 1.7
Mod Date: 5/21/2015
Contact : 5276
Copy of this file is located in OneNote under Scripts

Requirements - VMware PowerCLI

Versions
1.0 New Script
1.1 Added a confirm statement
1.2 Added 
    -Auto COOP list 
    -File Import COOP list 
    -Removal of old COOP files 
    -Test for File and DC servers 
    -Cleaner Write to Host
1.3 Added Case statement and Functions
1.4 Added 
    -Expanded information in this section
    -Changed some hard data to variables
    -Cleaned up some code
1.5 Removed
    -File import
    Added
    -While Loop
    -Better format for testing vm's
1.6 Added
    - confirm:$true to the "Remove-COOPs" function to prevent acidential deletions
1.6.1 Removed
    - Running all the copies at once was stressing the system so the "-runasync" was removed from create command.  
1.6.2 Modified the "Create COOP" section
    - Added a "clear-host" between each COOP with an actively built list of "Completed" COOPs
1.7 Added "Safety-Switch
    - Added Info-COOP-Snaps to get a dashboard of the VM's that you might be working on.
    -Moved the Menu into a function Menu-Main

#>

# Functions

Function Safety-Switch ($toggle){
	If ($WhatIfPreference -eq $true){
		$Script:WhatIfPreference = $false
		Write-Host "Safety is OFF - Script will run" -ForegroundColor Red
	}
	else{$Script:WhatIfPreference = $true
		Write-Host "Safety is ON" -ForegroundColor Green}
}

Function Main-Header {
	Write-Host `n 
	Write-Host "Datastore to be written to: "$DataStoreStore
	Write-Host "VM Host to store COOPs: "$VMHostIP
	Write-Host "Current File Location: " $local
}

Function Main-Menu {
	Write-Host `n 
	Write-Host "0 = Set Safety On/Off"
	Write-Host "1 = Remove Old COOPs and Create New"
	Write-Host "2 = Remove Old COOPs"
	Write-Host "3 = Create New COOPs"
	Write-Host "4 = VM/COOP information"
	Write-Host "E = to Exit"
	Write-Host `n 
}

Function Get-VMinformation {
	# User settings
	$Script:VMHostIP = "214.54.192.18"
	$Script:WhatIfPreference = $true #This is a safety measure that I am working on.  My scripts will have a safety mode, or punch the monkey to actually execute.  You can thank Phil West for this idea, when he removed all of the printers on the print server when he double-clicked on a vbs script.
	$Script:MainMenuChoice = 0 # Sets main menu choice
	$Script:VMServerList = ".\COOP-serverlist.csv" # The list of servers 
	$Script:VMDataStoreStore = Get-Datastore | where {$_.name -like "LOCALdatastore18"}


	# Script Variables
	$Script:HostsAll = get-vmhost # All hosts controlled by vcenter
	$Script:HostsLocal = get-vmhost | where {$_. } # All hosts in current site
	$Script:VMpoweredON = get-vm | where {$_.PowerState -eq "PoweredOn"} # All powered ON VMs
	$Script:VMPoweredOff = get-vm | where {$_.PowerState -eq "PoweredOff"} # All powered OFF VMs
	$Script:VMtags = get-tags # Tags on vcenter
	$Script:VMsnapshots = get-snap # All Snapshots

	$Script:local = Get-Location

	Set-Location .\ 

}

Function Info-COOPs-Snaps {

	$PoweredOffVM = get-vm | where {($_.PowerState -eq "PoweredOff") -and ($_.Name -notmatch "COOP")}# | Format-Table -AutoSize
	$COOPSinuse = get-vm | where {($_.PowerState -eq "PoweredOn") -and ($_.Name -match "COOP")}
	$Snapshotinfo = get-vm | get-snapshot 

	# $PoweredOffVM = get-vm | where {($_.PowerState -eq "PoweredOff") -and ($_.Name -notmatch "COOP")}# | Format-Table -AutoSize

	# Regular VM's which are in a powered off state
	Write-Host `n "Regular VM's with the Power turned OFF." -foreground Black -BackgroundColor Cyan
	Write-Host "=============================" -foregroundcolor Cyan
	If ($PoweredOffVM.count -ne 0){
		Write-Host -sep `n $PoweredOffVM -foregroundcolor Cyan
	}
	else{
		Write-Host "`nNone to Report." -foregroundcolor Cyan 
	}
	Write-Host "=============================" -foregroundcolor Cyan
	Write-Host -sep `n 

	# COOP Server In use
	Write-Host `n "COOP'ed Servers with the Power ON." -foreground White -BackgroundColor Red
	Write-Host "=============================" -foregroundcolor Red
	If ($PoweredOffVM.count -ne 0){
		Write-Host -sep `n $COOPSinuse -foregroundcolor Red
	}
	else{
		Write-Host "`nNone to Report." -foregroundcolor Red
	}
	Write-Host "=============================" -foregroundcolor Red
	Write-Host -sep `n 

	# Snapshot Information
	Write-Host `n "Snapshot information of all VM's in our vSphere." -foreground Yellow -BackgroundColor Black
	Write-Host "=============================" -foregroundcolor Yellow

	If ($Snapshotinfo.count -ne 0){
		Write-Host -sep `n $Snapshotinfo | Format-table -a -foregroundcolor Yellow
	}
	else{
		Write-Host "`nNone to Report." -foregroundcolor Yellow
	}
	Write-Host "=============================" -foregroundcolor Yellow
}

Function Old-Info-COOPs-Snaps {

	get-tag
	Write-Host "============================="
	Write-Host `n 
	$PoweredOffVM = get-vm | where {($_.PowerState -eq "PoweredOff") -and ($_.Name -notmatch "COOP")}# | Format-Table -AutoSize
	If ($PoweredOffVM.count -ne 0){
		Write-Host `n "Regular VM's with the Power turned OFF." -foreground Black -BackgroundColor Cyan
		Write-Host "=============================" -foregroundcolor Cyan
		Write-Host -sep `n $PoweredOffVM -foregroundcolor Cyan #| Format-Table -AutoSize
		Write-Host "=============================" -foregroundcolor Cyan
		Write-Host -sep `n 
	}
	$COOPSinuse = get-vm | where {($_.PowerState -eq "PoweredOn") -and ($_.Name -match "COOP")}
	If ($COOPSinuse.count -ne 0){
		Write-Host `n "COOP'ed Servers with the Power ON." -foreground White -BackgroundColor Red
		Write-Host "=============================" -foregroundcolor Red
		Write-Host -sep `n $COOPSinuse -foregroundcolor Red
		Write-Host "=============================" -foregroundcolor Red
		Write-Host -sep `n 
	}
	$Snapshotinfo = get-vm | get-snapshot | Sort-Object Created,SizeGB -Desc | Format-Table -Property VM,Name,Created,@{n="SizeGb";e={"{0:N2}" -f $_.SizeGb}}#, id -AutoSize
	If ($Snapshotinfo.count -ne 0){
		Write-Host `n "Snapshot information of all VM's in our vsphere." -foreground Yellow -BackgroundColor Black
		Write-Host "=============================" -foregroundcolor Yellow
		$Snapshotinfo | Format-Table
		Write-Host "=============================" -foregroundcolor Yellow
	}
}

Function Remove-COOPs {
	
    
    if ($MainMenuChoice -eq "2"){Clear-Host}

	#Get List of all VM's with "COOP" in the name. This will be used as the list of COOP's that will be deleted.
	$VMServers = get-vm | where {$_.Name -match "COOP"}
	$VMServers | Format-Table Name

	#Enter the date of the COOP vms that you want to remove.  From the printout of the list above, you will be able to select the unwanted dates.
	$COOPdate = Read-Host "Enter the date of the COOP you want to remove (YYYYMMDD) "

	#Get List of the VM Clones you want to Remove.  This is similar to the first step, but uses the specific date you gave to search on.  This will be your list of systems to remove.
	$PoweredOffClones = $VMPoweredOff | where {$_.Name -like "$COOPdate*"} #| ft Name, ResourcePool  -AutoSize

	#Set "$OkRemove" to "N" 
	$OkRemove = "N"
	$OkRemove = Read-host "Preparing to remove ALL COOP'ed vm servers below. $PoweredOffClones`nIs this Okay? [N] "

	If ($OkRemove -eq "Y"){
		#Remove older COOP's from the list you created in the early part of the script.
		foreach ($VMz in $PoweredOffClones) {
			Write-Host -sep `n "Checking to ensure $VMz is Powered Off." #-foregroundcolor Red
			If (($VMz.PowerState -eq "PoweredOff") -and ($VMz.Name -match "COOP")){
				Write-Host -sep `n $VMz "is in a Powered Off state and will be removed. " -foregroundcolor Blue 
				#Write-Host "Remove-VM $VMz -DeletePermanently -confirm:$true "
				Remove-VM $VMz -DeletePermanently -confirm:$true -runasync 

			}}}
}

Function Create-COOPs {
	if ($MainMenuChoice -eq "3"){Clear-Host}

	#get-vm *gm* -tag "COOPdr" | where {$_.powerstate -eq "PoweredOn"} | ft Name, ResourcePool -AutoSize
	#$VMServer  = get-vm *gm* | where {($_.powerstate -eq "PoweredOn") -and ($_.ResourcePool -like "Standard Server*") -and ($_.name -ne "rsrcngmfs02") -and ($_.name -ne "RSRCNGMNB01") -and ($_.name -ne "rsrcngmfs01") -and ($_.name -ne "rsrcngmcmps01")} | select Name, ResourcePool
	#get-vm *gm* | where {($_.powerstate -eq "PoweredOn") -and ($_.ResourcePool -like "Standard Server*") -and ($_.name -ne "rsrcngmfs02") -and ($_.name -ne "RSRCNGMNB01") -and ($_.name -ne "rsrcngmfs01") -and ($_.name -ne "rsrcngmcmps01")} | ft Name, ResourcePool -AutoSize

	$VMServer = VMpoweredON | where{($_.name -match "gm") -and ($_ -tag "COOPdr")}
#$VMServer = get-vm *gm* -tag "COOPdr" | where {$_.powerstate -eq "PoweredOn"}

	#Create Time/Date Stamp
	$TDStamp = Get-Date -UFormat "%Y%m%d" 

	#Prefix of Name of COOP
	$COOPPrefix = $TDStamp + "-COOP." 

	Write-Host "`nInformation to be used to create the COOPs: $VMServer.Name - $VMServer.ResourcePool" -foregroundcolor black -backgroundcolor yellow #
	Write-Host -Separator `n $VMServer | ft Name,ResourcePool -AutoSize 
	Write-Host "Writing to: "$DataStoreStore -foregroundcolor Yellow
	Write-Host "On VM Host: "$VMHostIP -foregroundcolor Yellow
	Write-Host "Example of COOP file name: "$COOPPrefix$($VMServer.Name[1]) -foregroundcolor Yellow
	Write-Host -Separator `n 

	#Set "$OkADD" to "N" and confirm addition of COOPs
	$OkADD = "N"
	$OkADD = Read-host "Preparing to Create ALL New COOP servers with information above. `nIs this Okay? Y,S,[N] "

	switch ($OkAdd){
		Y {
			foreach ($server in $VMserver) {
				Write-Host -Separator `n "Completed"
				Write-Host "=============================" -foregroundcolor Yellow
				get-vm | where {$_.Name -like $TDStamp + "-COOP.*"} | Format-Table Name
				Write-Host "New COOP Name: "$COOPPrefix$($server) "In ResourcePool: "$Server.ResourcePool -foregroundcolor Green -backgroundcolor black
				#Create the COOP copies with the information assigned to these var ($COOPPrefix, $VMserver, $dataStoreStore)
				#Write-Host "-name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -ResourcePool"$Server.ResourcePool
				New-vm -name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -ResourcePool $Server.ResourcePool 
			}
		}
		S {
			$server = Read-Host "Single COOP (ServerName) " 
			$COOPPrefix + $server
			New-vm -name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -whatif
		}
		Default {Write-Host "Exit"}
	}}


# -----  Begin Script -----

Clear-Host

Do {
	Main-Header
	Main-Menu
	$MainMenuChoice = Read-Host "Create and/or Remove and Create VM's"
	if($MainMenuChoice -eq 0){
		Safety-Switch}
}Until ($MainMenuChoice -eq "1" -or $MainMenuChoice -eq "2" -or $MainMenuChoice -eq "3" -or $MainMenuChoice -eq "4" -or $MainMenuChoice -eq "E")


switch ($MainMenuChoice){
	1 {Clear-Host;
		Write-Host "Start Removing COOPs" -ForegroundColor Green
		Remove-COOPs; 
		Write-Host "Start Creating COOP's" -ForegroundColor Green
		Create-COOPs}
	2 {Clear-Host;
		Write-Host "Start Removing COOPs" -ForegroundColor Green
		Remove-COOPs}
	3 {Clear-Host;
		Write-Host "Start Creating COOP's" -ForegroundColor Green
		Create-COOPs}
	4 {Clear-Host;
		Info-COOPs-Snaps}
	Default {
		Clear-Host;
		Write-Host "Exit" -ForegroundColor Red}
}




# SIG # Begin signature block
# MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUC8j5y+P7BINvRBDBjndw0Zc9
# 1Z+gggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
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
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQULXoTnYWwMoJemALDWzDfgMDTWjYw
# DQYJKoZIhvcNAQEBBQAEgYCTq6RF1RYqP6ADaeHKgK9PO9W9RnkOHVkqW+eoiTQa
# xPPQ8AL5Ddl52/DVkbM5OxOXZUYCC3nXFihPkhh336cNgtd0qpIb9Re395nZJ7yv
# RCmzBn2FFohvEhX6WxBbl1QU56Y79nd/OE15NL3iAiw8paZpouuOcQHyUs+LOp1K
# nQ==
# SIG # End signature block
