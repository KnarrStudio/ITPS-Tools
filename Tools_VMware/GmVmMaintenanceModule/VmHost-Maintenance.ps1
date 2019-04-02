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


# ^^^^^^^^^^^^  Variables ^^^^^^^^^^
   
$script:MenuItems         = @('Set Safety On/Off',"Move all VM's to one host",'Reboot Empty host',"Balance all VM's per 'tag'",'Move, Reboot and Balance VM environment','VM/Host information')
$script:NewBlankLine = "`n"
$Script:WarningFontColor = 'DarkYellow'

$script:WhatIfPreference = $true <#This is a safety measure that I am working on.  My scripts will have a safety mode, or punch the monkey to actually execute.  You can thank Phil West for this idea, when he removed all of the printers on the print server when he double-clicked on a vbs script.#>
$MenuSelection           = 0
#$ServerList            = '.\COOP-serverlist.csv'
#$DataStoreStore        = Get-Datastore | Where-Object {$_.name -like 'LOCALdatastore*'}
#$VMHostIP              = '192.168.1.18'
$local                   = Get-Location
$rebootOther             = 'y'
$balance                 = 'y'
Set-Location -Path .\ 



#  ======= Functions  Below =======
Function Switch-Safety() 
{ 
   If ($WhatIfPreference -eq $true){
      $script:WhatIfPreference = $false
   $WhatIfPreference}
   else{ 
      $script:WhatIfPreference = $true
   $WhatIfPreference}
} # End Function - Switch-Safety

Function Show-MainMenu
{
   Clear-Host
   If ($WhatIfPreference -eq $true){
   Write-Host 'Safety is ON - Script is TESTING MODE' -BackgroundColor DarkGreen }
   else{
      Write-Host 'Safety)
         Write-Host is OFF - Script is 
   Write-Host ctive and will make changes' -BackgroundColor Red }
   Write-Host $NewBlankLine
   Write-Host 'Welcome to the Maintenance Center' -BackgroundColor Yellow -ForegroundColor DarkBlue
   Write-Host $NewBlankLine
   for($i = 0; $i -lt $MenuItems.Length-1;$i++){Write-Host $i' = ' -NoNewline; $MenuItems[$i]}
   Write-Host $NewBlankLine 
} # End Function - Show-MainMenu

function script:Get-VmsOnHost
{
   param
   (
      [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Data to filter')]
      $InputObject
   )
   process
   {
      if ($InputObject.vmhost.name -eq $Script:HostFromName)
      {
         $InputObject
      }
   }
}
function Script:Move-VMs
{
   param
   (
      [Parameter(Mandatory,HelpMessage='The Host to move VMs FROM')]$HostFromName,
      [Parameter(Mandatory,HelpMessage='The Host to move VMs TO')]$HostToName,
      [string]$Host1Tag = 'Host_18',
      [string]$Host2Tag = 'Host_19',
      [Switch]$TagSwitch
   )

   # Variables
   $ShuttingDownTextColor = 'Magenta'
   $MissionCompleteColor  = 'Green'
   $WarningTextColor      = 'DarkYellow'
   $ServersList           = Get-VM
   
   if($TagSwitch)
   {
      foreach($server in $ServersList)
      {
         if(($server.vmhost.name -ne $HostFromName) -and ($Server.tag -contains $Host1Tag))
         {
            Write-Host ('Moving {0} to {1}' -f $server, $HostFromName) -ForegroundColor $WarningTextColor 
            move-vm $server -Destination $HostFromName #-whati
         }
         Else{
            if(($server.vmhost.name -ne $HostToName) -and ($Server.tag -contains $Host2Tag))
            {
               Write-Host ('Moving {0} to {1}' -f $server, $HostToName) -ForegroundColor $WarningTextColor 
               move-vm $server -Destination $HostToName #-whatif
            }
         }
      }
   }
   Else{
      do{
         $servers = get-vm | Get-VmsOnHost
         foreach($server in $servers){
            Write-Host ('Moving {0} from {1} to {2}' -f $server, $HostFromName, $HostToName) -forgroundColor $WarningTextColor
            move-vm $server -Destination $HostToName
         }
      }while((get-vm | Get-VmsOnHost).count -ne 0)

      Write-Host 'Moves Completed!' -ForegroundColor $MissionCompleteColor
   }
}

function Restart-Hosts
{
   param
   (
      [Parameter(Mandatory,HelpMessage='The Host to move VMs FROM')]$Host1Name,
      [Parameter(Mandatory,HelpMessage='The Host to move VMs TO')]$Host2Name
   )
  
   # Variables
   $ShuttingDownTextColor = 'Magenta'
   $SleepSeconds          = 15
  
   # Move VMs 
   Move-VMs $Host1Name $Host2Name # End Function Move-VMs

   if((get-vm | Get-VmsOnHost).count -eq 0){
      $null = Set-VMHost $Host1Name -State Maintenance
      $null = Restart-vmhost $Host1Name -confirm:$false 
   }
   do {Start-Sleep -Seconds $SleepSeconds
      $ServerState = (get-vmhost $Host1Name).ConnectionState
      Write-Host ('Shutting Down {0}' -f $Host1Name) -ForegroundColor $ShuttingDownTextColor
   } while ($ServerState -ne 'NotResponding')
   Write-Host ('{0} is Down' -f $Host1Name) -ForegroundColor $ShuttingDownTextColor

   do {Start-Sleep -Seconds 60
      $ServerState = (get-vmhost $Host1Name).ConnectionState
      Write-Host 'Waiting for Reboot ...'
   } while($ServerState -ne 'Maintenance')
   Write-Host ('{0} back online' -f $Host1Name)
   $null                  = Set-VMHost $Host1Name -State Connected 
} # End - function Restart-Hosts


# Begin Script
# ---------------------------------------------------------------------------

   
Do {
   $MenuSelection = $null

   Show-MainMenu

   $MenuSelection = Read-Host -Prompt 'Enter a selection from above'
   Clear-host
   $LocalHosts              = Get-VMHost | Where-Object {$_.name -notlike 'Local*'}
   $LocalHosts.name | Format-Table -Property Name
   
   switch ($MenuSelection#$switchSelection
   ){
      0 { Switch-Safety}
      1 { $LocalHosts.name | Format-Table -Property Name
         $Host1Name             = Read-Host -Prompt 'Enter the host IP Address you want to reboot'
         $Host2Name             = Read-Host -Prompt 'Enter other host' # $NorfolkHosts.name -ne $Host1Name | Out-String
         Restart-Hosts $Host1Name $Host2Name
         $rebootOther           = Read-Host -Prompt 'Would you like to reboot the other host [y]/n '
         if($rebootOther -eq 'y'){
            Restart-Hosts $Host2Name $Host1Name
      }}
      2 { $balance               = Read-Host -Prompt 'Would you like to balance the servers [y]/n '
         if($balance -eq 'y'){
            Optimize-HostsDistributeVms
      }}
      3 {
         $Host1Name = Read-Host -Prompt 'Enter IP Address of host to move from'
         $Host2Name = Read-Host -Prompt 'Enter IP Address of host to move to'
         Write-Host "If this is taking to long to run, manually check status of servers by running 'get-vm | ft name, vmhost' from PowerCLI" -ForegroundColor $WarningFontColor
         Write-Host "This processes can be completed by using the following command in the PowerCLI: 'move-vm VM-SERVER -destination VM-HOST'" -ForegroundColor $WarningFontColor
         if($Host2Name -ne $Host1Name){ Move-VMs $Host1Name $Host2Name}
      }
      4 { Remove-COOPs }
      5 { Create-COOPs }
      6 { Optimize-HostsDistributeVms }
      7 {}
      Default {Write-Host 'Exit'
      }
   }
}Until($MenuSelection -eq 99)

