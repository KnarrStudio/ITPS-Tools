<#
    .SYNOPSIS
    This Script migrates all machines to one host so you can reboot the empty one.
    .DESCRIPTION
    <A detailed description of the script>
    .PARAMETER <paramName>
    <Description of script parameter>
    .EXAMPLE
    <An example of using the script>
#>



# Functions 
$WarningFontColor = 'DarkYellow'
Function Switch-Safety{
  If ($WhatIfPreference -eq $true){
  Write-Host 'Safety is ON - Script is TESTING MODE' -BackgroundColor DarkGreen }
  else{
  Write-Host 'Safety is OFF - Script is active and will make changes' -BackgroundColor Red }
} # End Function - Switch-Safety

Function Show-MainMenu{
  $NewBlankLine = '`n'
Clear-Host
  Switch-Safety
  Write-Host $NewBlankLine
  Write-Host 'Welcome to the Maintenance Center' -BackgroundColor Yellow -ForegroundColor DarkBlue
  Write-Host $NewBlankLine
  #Write-Host "Datastore to be written to: "(get-datastore).name #$DataStoreStore
  #Write-Host "VM Host to store COOPs: "$VMHostIP
  #Write-Host "Current File Location: " $local
  Write-Host $NewBlankLine 
  Write-Host '0 = Set Safety On/Off'
  Write-Host "1 = Move all VM's to one host"
  Write-Host '2 = Reboot Empty host'
  Write-Host "3 = Balance all VM's per 'tag'"
  Write-Host '4 = Move, Reboot and Balance VM environment'
  Write-Host '5 = VM/Host information'
  Write-Host 'E = to Exit'
  Write-Host $NewBlankLine 
} # End Function - Show-MainMenu

function Get-FromHostVms
{
  param
  (
    [Object]
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Data to filter')]
    $InputObject
  )
  process
  {
    if ($InputObject.vmhost.name -eq $HostFromName)
    {
      $InputObject
    }
  }
}
function Move-VMs{
  


  
  [CmdletBinding()]
  param
  (
    [Object]$HostFromName,

    [Object]$HostToName
  )
do{
    $servers = get-vm | Get-FromHostVms
    foreach($server in $servers){
      #Moving $server from $Host1Name to $Host2Name
      move-vm $server -Destination $HostToName
    }
  }while((get-vm | Get-FromHostVms).count -ne 0)

  Write-Host 'Moves Completed!' -ForegroundColor Green
} # End Function - Move-VMs



function Restart-Hosts{
  
  [CmdletBinding()]
  param
  (
    [Object]$Host1Name,

    [Object]$Host2Name
  )
$ShuttingDownTextColor = 'Magenta'
do{
    $servers = get-vm | Get-FromHostVms
    foreach($server in $servers){
      #Write-Host "Moving $server from $Host1Name to $Host2Name"
      move-vm $server -Destination $Host2Name
    }
  }while((get-vm | Get-FromHostVms).count -ne 0)

  if((get-vm | Get-FromHostVms).count -eq 0){
    Set-VMHost $Host1Name -State Maintenance | Out-Null
    Restart-vmhost $Host1Name -confirm:$false | Out-Null 
  }
  do {Start-Sleep -Seconds 15
    $ServerState = (get-vmhost $Host1Name).ConnectionState
    Write-Host ('Shutting Down {0}' -f $Host1Name) -ForegroundColor $ShuttingDownTextColor
  } while ($ServerState -ne 'NotResponding')
  Write-Host ('{0} is Down' -f $Host1Name) -ForegroundColor $ShuttingDownTextColor

  do {Start-Sleep -Seconds 60
    $ServerState = (get-vmhost $Host1Name).ConnectionState
    Write-Host 'Waiting for Reboot ...'
  } while($ServerState -ne 'Maintenance')
  Write-Host ('{0} back online' -f $Host1Name)
  Set-VMHost $Host1Name -State Connected | Out-Null 
} # End - function Restart-Hosts

function Optimize-HostsDistributeVms (){

  [CmdletBinding()]
  param(
    [string]$Host1Name = '192.168.1.18',
    [string]$Host2Name = '192.168.1.19',
    [string]$Host1Tag = 'Host_18',
    [string]$Host2Tag = 'Host_19'
  )

  $ServersList = Get-VM

  foreach($server in $ServersList){
    if(($server.vmhost.name -ne $Host1Name) -and ($Server.tag -contains $Host1Tag))
    {
      Write-Host ('Moving {0} to {1}' -f $server, $Host1Name) -ForegroundColor DarkYellow
      move-vm $server -Destination $Host1Name #-whatif
    }
  }
  Else{
    if(($server.vmhost.name -ne $Host2Name) -and ($Server.tag -contains $Host2Tag))
    {
      Write-Host ('Moving {0} to {1}' -f $server, $Host2Name) -ForegroundColor DarkYellow
      move-vm $server -Destination $Host2Name #-whatif
    }
  }
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


$NorfolkHosts = Get-VMHost | Where-Object {$_.name -notlike '214.54.208.*'}
$NorfolkHosts.name | Format-Table -Property Name


# Begin Script
$WhatIfPreference = $true <#This is a safety measure that I am working on.  My scripts will have a safety mode, or punch the monkey to actually execute.  You can thank Phil West for this idea, when he removed all of the printers on the print server when he double-clicked on a vbs script.#>
$MenuSelection = 0
$ServerList = '.\COOP-serverlist.csv'
$DataStoreStore = Get-Datastore | Where-Object {$_.name -like 'LOCALdatastore*'}
$VMHostIP = '192.168.1.18'
$local = Get-Location


Set-Location -Path .\ 

# Begin Script
#Get list of Norfolk VM's under control of vCenter
$rebootOther = 'y'
$balance = 'y'
$NorfolkHosts = Get-VMHost | Where-Object {$_.name -notlike '192.168.3.*'}



Do {
  $MenuSelection = ''

  #Show-MainMenu
  CreateMenu -Title 'Welcome to the Maintenance Center' -MenuItems 'Set Safety On/Off','EXIT',"Move all VM's to one host",'Reboot Empty host',"Balance all VM's per 'tag'",'Move and Reboot and Balance VM environment','VM/Host information','Exit' -TitleColor Red -LineColor Cyan -MenuItemColor Yellow

  $MenuSelection = Read-Host -Prompt 'Enter a selection from above'
  if($menuSelection -eq 1){
    If ($WhatIfPreference -eq $true){
    $WhatIfPreference = $false}
  else{$WhatIfPreference = $true}}

}Until ($MenuSelection -eq '1' <# Move all VM's to one host #> -or 
  $MenuSelection -eq '2' <# Put host in Maintenance Mode #> -or 
  $MenuSelection -eq '3' <# Reboot Empty host #> -or 
  $MenuSelection -eq '4' <# Balance all VM's per 'tag' #> -or
  $MenuSelection -eq '5' <# Move, Reboot and Balance VM environment #> -or 
$MenuSelection -eq 'E' <# Exit #> )



switch ($MenuSelection){
  3 {
    Clear-Host
    $Host1Name = Read-Host -Prompt 'Enter IP Address of host to move from'
    $Host2Name = Read-Host -Prompt 'Enter IP Address of host to move to'
    Write-Host "If this is taking to long to run, manually check status of servers by running 'get-vm | ft name, vmhost' from PowerCLI" -ForegroundColor $WarningFontColor
    Write-Host "This processes can be completed by using the following command in the PowerCLI: 'move-vm VM-SERVER -destination VM-HOST'" -ForegroundColor $WarningFontColor
    if($Host2Name -ne $Host1Name){
      Move-VMs $Host1Name $Host2Name
  }}
  4 {
    Clear-Host
  Remove-COOPs}
  5 {
    Clear-Host
  Create-COOPs}
  6 {
    Clear-Host
  Optimize-HostsDistributeVms}
  7 {}
  Default {Write-Host 'Exit'}
}


Start-Sleep -Seconds 4
Clear-Host

$NorfolkHosts.name | Format-Table -Property Name
$Host1Name = Read-Host -Prompt 'Enter the host IP Address you want to reboot'
$Host2Name = Read-Host -Prompt 'Enter other host' # $NorfolkHosts.name -ne $Host1Name | Out-String
Restart-Hosts $Host1Name $Host2Name

$rebootOther = Read-Host -Prompt 'Would you like to reboot the other host [y]/n: '
if($rebootOther -eq 'y'){
  Restart-Hosts $Host2Name $Host1Name
}

$balance = Read-Host -Prompt 'Would you like to balance the servers [y]/n: '
if($balance -eq 'y'){
  Optimize-HostsDistributeVms
}


