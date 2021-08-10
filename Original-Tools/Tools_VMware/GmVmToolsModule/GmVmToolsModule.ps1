
Function Show-SafetyDisplay{
   
  If ($WhatIfPreference -eq $true){
  Write-Verbose -Message 'Safety is ON' }
  else{
  Write-Verbose -Message 'Safety is OFF - Script will run'  }
}

Function Set-SafetySwitch(){

  $COOPprocess
  $WhatIfPreference
  If ($COOPprocess -eq 0){    
    If ($WhatIfPreference -eq $true){
    $WhatIfPreference = $false}
    else{$WhatIfPreference = $true}
  }
  $COOPprocess
  return $WhatIfPreference
}

Function Show-MenuMain{

  Write-Host $DoubleLine
  Write-Host '0 = Set Safety On/Off'
  Write-Host '1 = Remove Old COOPs and Create New'
  Write-Host '2 = Remove Old COOPs'
  Write-Host '3 = Create New COOPs'
  Write-Host '4 = VM/COOP information'
  Write-Host 'E = to Exit'
  Write-Host `n
}

Function Get-CurrentVMInformation {
 
  $ALLvms = get-vm
  $Snapshots = get-vm | get-snapshot
  $AllHost = Get-VMHost 

  $PoweredOffVM = $ALLvms | Where-Object {($_.PowerState -eq 'PoweredOff')}
  $PoweredOnVM = $ALLvms | Where-Object {($_.PowerState -eq 'PoweredOn')}

  $COOPSinuse = $ALLvms | Where-Object {($_.Name -like '*COOP*') -and ($_.PowerState -eq 'PoweredOn')}
  $Snapshotsinfo = $Snapshots | Sort-Object -Property Created,SizeGB -Descending | Select-Object -Property VM,Name,Created,@{n="SizeGb" -InputObject e=-Property {"{0:N2}" -f $_.SizeGb}}#, id -AutoSize

  Write-Host `n 
  Write-Host 'Datastore to be written to: '$DataStoreStore
  Write-Host 'VM Host to store COOPs: '$VMHostIP
  Write-Host 'Current File Location: ' $local

}

function Get-VMInformation{

  # Get list of all VM's
  $VMServers  = Get-vm

  # Get list of All Hosts 
  $VMHosts = Get-VMhosts

  # Get list of all snapshots
  $VMSnapshots = $VMServers | Get-Snapshots

  # Get list of all powered off servers
  $VMPoweredOff = $VMServers | Where-Object {$_.PowerState -eq 'PoweredOff'}

  # Get list of all powered on servers
  $VMPoweredOn = $VMServers | Where-Object {$_.PowerState -eq 'PoweredOn'}

}

Function Get-CloneAndSnapshotInfo {
  

  $NewLine = "`n"
  $DoubleLine = '============================='
  get-tag
  Write-Host $DoubleLine
  Write-Host $NewLine 
  $PoweredOffVM = get-vm | Where-Object {($_.PowerState -eq 'PoweredOff') -and ($_.Name -notlike '*COOP*')}# | Format-Table -AutoSize
  If ($PoweredOffVM.count -ne 0){
    Write-Host $NewLine "Regular VM's with the Power turned OFF."  -foreground Black -BackgroundColor Cyan
    Write-Host $DoubleLine -foregroundcolor Cyan
    Write-Host -sep $NewLine $PoweredOffVM  -foregroundcolor Cyan #| Format-Table -AutoSize
    Write-Host $DoubleLine -foregroundcolor Cyan
    Write-Host -sep $NewLine 
  }
  $COOPSinuse = get-vm | Where-Object {($_.Name -like '*COOP*') -and ($_.PowerState -eq 'PoweredOn')}
  If ($COOPSinuse.count -ne 0){
    Write-Host $NewLine "COOP'ed Servers with the Power ON."  -foreground White -BackgroundColor Red
    Write-Host $DoubleLine -foregroundcolor Red
    Write-Host -sep $NewLine $COOPSinuse -foregroundcolor Red
    Write-Host $DoubleLine -foregroundcolor Red
    Write-Host -sep $NewLine 
  }
  $Snapshotinfo = get-vm | get-snapshot  | Sort-Object -Property Created,SizeGB -Descending | Select-Object -Property VM,Name,Created,@{n="SizeGb"
  e={"{0:N2}" -f $_.SizeGb}}#, id -AutoSize
  If ($Snapshotinfo.count -ne 0){
    Write-Host $NewLine "Snapshot information of all VM's in our vsphere." -foreground Yellow -BackgroundColor Black
    Write-Host $DoubleLine -foregroundcolor Yellow
    $Snapshotinfo  | Select-Object -Property *
    Write-Host $DoubleLine -foregroundcolor Yellow
  }
}

Function Remove-VmClones {
 
  if ($COOPprocess -eq '2'){Clear-Host}

  #Get List of all VM's with "COOP" in the name. This will be used as the list of COOP's that will be deleted.
  $VMServers  = get-vm | Where-Object {$_.Name -like '*COOP*'}
  get-vm | Where-Object {$_.Name -like '*COOP*'} | Select-Object -Property Name

  #Enter the date of the COOP vms that you want to remove.  From the printout of the list above, you will be able to select the unwanted dates.
  $COOPdate = Read-Host -Prompt 'Enter the date of the COOP you want to remove (YYYYMMDD) '

  #Get List of the VM Clones you want to Remove.  This is similar to the first step, but uses the specific date you gave to search on.  This will be your list of systems to remove.
  $VMSvr = $VMServers | Where-Object {($_.Name -like ('{0}*' -f $COOPdate)) -and ($_.PowerState -eq 'PoweredOff')} #| ft Name, ResourcePool  -AutoSize

  Write-Host -sep `n "Preparing to remove ALL COOP'ed vm servers below." $VMSvr -foreground Red

  #Set "$OkRemove" to "N" 
  $OkRemove = 'N'
  $OkRemove = Read-host -Prompt 'Is this Okay? [N] '

  If ($OkRemove -eq 'Y'){
    #Remove older COOP's from the list you created in the early part of the script.
    foreach ($VMz in $VMSvr) {
      Write-Host -sep `n ('Checking to ensure {0} is Powered Off.' -f $VMz) #-foregroundcolor Red
      If (($VMz.PowerState -eq 'PoweredOff') -and ($VMz.Name -like '*COOP*')){
        Write-Host -sep `n $VMz 'is in a Powered Off state and will be removed. ' -foregroundcolor Blue 
        #Write-Host "Remove-VM $VMz -DeletePermanently -confirm:$true "
        Remove-VM $VMz -DeletePermanently -confirm:$true -runasync 

  }}}
}

Function New-VmClones {
  
  if ($COOPprocess -eq '3'){Clear-Host}

  #get-vm *gm* -tag "COOPdr" | where {$_.powerstate -eq "PoweredOn"} | ft Name, ResourcePool -AutoSize
  #$VMServer  = get-vm *gm* | where {($_.powerstate -eq "PoweredOn") -and ($_.ResourcePool -like "Standard Server*") -and ($_.name -ne "rsrcngmfs02") -and ($_.name -ne "RSRCNGMNB01") -and ($_.name -ne "rsrcngmfs01") -and ($_.name -ne "rsrcngmcmps01")} | select Name, ResourcePool
  #get-vm *gm* | where {($_.powerstate -eq "PoweredOn") -and ($_.ResourcePool -like "Standard Server*") -and ($_.name -ne "rsrcngmfs02") -and ($_.name -ne "RSRCNGMNB01") -and ($_.name -ne "rsrcngmfs01") -and ($_.name -ne "rsrcngmcmps01")} | ft Name, ResourcePool -AutoSize

  $VMServer  = get-vm *gm* -tag 'COOPdr' | Where-Object {$_.powerstate -eq 'PoweredOn'}

  #Create Time/Date Stamp
  $TDStamp = Get-Date -UFormat '%Y%m%d' 

  #Prefix of Name of COOP
  $COOPPrefix = $TDStamp+'-COOP.' 

  Write-Host -Separator `n 
  Write-Host 'Information to be used to create the COOPs: ' -foregroundcolor black -backgroundcolor white #
  Write-Host -Separator `n $VMServer | Select-Object -Property Name,ResourcePool 
  Write-Host -Separator `n 
  Write-Host $DoubleLine -foregroundcolor Yellow
  Write-Host 'Writing to: '$DataStoreStore -foregroundcolor Yellow
  Write-Host 'On VM Host: '$VMHostIP -foregroundcolor Yellow
  Write-Host 'Example of COOP file name: '$COOPPrefix$($VMServer.Name[1]) -foregroundcolor Yellow
  Write-Host -Separator `n 

  #Set "$OkADD" to "N" and confirm addition of COOPs
  $OkADD = 'N'
  Write-Host 'Preparing to Create ALL New COOP servers with information above. ' -NoNewline
  $OkADD = Read-host -Prompt 'Is this Okay? Y,S,[N] '

  switch ($OkAdd){
    Y {
      foreach ($server in $VMserver) {
        Clear-Host
        Write-Host -Separator `n 'Completed'
        Write-Host $DoubleLine -foregroundcolor Yellow
        get-vm | Where-Object {$_.Name -like $TDStamp+'-COOP.*'} | Select-Object -Property Name
        Write-Host 'New COOP Name: '$COOPPrefix$($server) 'In ResourcePool: '$Server.ResourcePool -foregroundcolor Green -backgroundcolor black
        #Create the COOP copies with the information assigned to these var ($COOPPrefix, $VMserver, $dataStoreStore)
        #Write-Host "-name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -ResourcePool"$Server.ResourcePool
        New-vm -name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -ResourcePool $Server.ResourcePool  
    }}
    S {
      $server = Read-Host -Prompt 'Single COOP (ServerName) ' 
      $COOPPrefix+$server
      New-vm -name $COOPPrefix$($server) -vm $server -datastore $DataStoreStore -VMHost $VMHostIP -Location COOP -whatif
    }
    Default {Write-Host 'Exit'}
}}

# Begin Script
$WhatIfPreference = $true #This is a safety measure that I am working on.  My scripts will have a safety mode, or punch the monkey to actually execute.  You can thank Phil West for this idea, when he removed all of the printers on the print server when he double-clicked on a vbs script.

$COOPprocess = 0

$ServerList = '.\COOP-serverlist.csv'

$DataStoreStore = Get-Datastore | Where-Object {$_.name -like 'ESXi06-LOCALdatastore02'}

$VMHostIP = '214.18.207.89'

$local = Get-Location


Do {
  Clear-Host
  Show-SafetyDisplay
  Menu-Main
  $COOPprocess = Read-Host -Prompt "Create and/or Remove and Create VM's"
  #Set-SafetySwitch $COOPprocess
  If ($COOPprocess -eq 0){    
    If ($WhatIfPreference -eq $true){
    $WhatIfPreference = $false}
  else{$WhatIfPreference = $true}}
}Until ("'1','2','3','4','E'" -match $COOPprocess)


switch ($COOPprocess){
  1 {Remove-VmClones New-VmClones}
  2 {Remove-VmClones}
  3 {New-VmClones}
  4 {Get-CloneAndSnapshotInfo}
  Default {Write-Host 'Exit'}
}


