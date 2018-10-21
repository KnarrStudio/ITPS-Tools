function Invoke-SystemShutdown{
   <#
         .SYNOPSIS
         Describe purpose of "Invoke-SystemShutdown" in 1-2 sentences.

         .DESCRIPTION
         Add a more complete description of what the function does.

         .EXAMPLE
         Invoke-SystemShutdown
         Describe what this call does

         .NOTES
         Place additional notes here.

         .LINK
         URLs to related sites
         The first link is opened by Get-Help -Online Invoke-SystemShutdown

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
   #>
   param(
      [Parameter(Mandatory,HelpMessage='Type of Shutdown.  Full= All VMs and Hosts, Partial = Only ones tagged, Test = None, but runs script)The Host to move VMs FROM')]
      [ValidatePattern(Full, Partial, Test)]
      [string]$ShutdownType
   ) # End - Invoke-SystemShutdown param
   Begin{
      $ServerList = .\ServerList.csv  ## List of servers in order of shutdown (Name,Order)
      $LogFileOutput = .\LogFileOutput.log ## File to write to as this script runs
      Clear-Host
      $ShutDownArgreement = "$env:HOMEDRIVE\temp\ShutDownArgreement" ## File holds information and steps for the shutdown process
  
  
      Get-Content -Path $ShutDownArgreement
      $SignAgreement = Read-Host -Prompt 'Do you agree and have the above information'
      if($SignAgreement -eq 'y'){
         $DateTimeStamp = Get-Date -UFormat %M%S #-%m/%d/%Y
         $SignedShutdownAgreement =  ('{0}-{1}.txt' -f $ShutDownArgreement, $DateTimeStamp)
         Copy-Item -Path $ShutDownArgreement -Destination $SignedShutdownAgreement
         Write-Output -InputObject ('Today {0}. I, {1}, agree to the Shutdown Agreement.' -f $DateTimeStamp, $env:username) | Out-File -FilePath $SignedShutdownAgreement -Append
      }Else{break}

      if($ShutdownType -eq 'Test'){
         If ($WhatIfPreference -ne $true){
            $script:WhatIfPreference = $true
            Write-Warning -Message ('Testing Mode is {0}' -f $WhatIfPreference)
         } # End - Switch-Safety
      }
   } # End - Begin Block
   Process {
      function Set-ServerService{
         <#
               .SYNOPSIS
               Describe purpose of "Set-DfsrService" in 1-2 sentences.

               .DESCRIPTION
               Add a more complete description of what the function does.

               .EXAMPLE
               Set-DfsrService
               Describe what this call does

               .NOTES
               Place additional notes here.

               .LINK
               URLs to related sites
               The first link is opened by Get-Help -Online Set-DfsrService

               .INPUTS
               List of input types that are accepted by this function.

               .OUTPUTS
               List of output types produced by this function.
         #>


         [CmdletBinding()]
         param([string]$ServiceName = 'DFSR',
            [string]$ServerName = 'iorunc-filesvr'
         )
         
         $a = Get-Service -ComputerName $ServerName -Name $ServiceName #-DependentServices
         $b = 'N'
         if ($a.Status -eq 'Stopped'){
            Write-Host 'DFS Replication Service is Off.... '
            $b = Read-Host -Prompt 'Do you want to start it? [N]'
            if($b -eq 'Y'){
               Write-Host 'Starting Service...' -BackgroundColor Green
               Set-Service -ComputerName $ServerName -Name $ServiceName -Status Running -StartupType Automatic
 
         }}
 
         if ($a.Status -eq 'Running'){
            Write-Host 'DFS Replication Service is On....'
            $b = Read-Host -Prompt 'Do you want to stop it? [N]'
            if($b -eq 'Y'){
               Write-Host 'Stopping Service...' -BackgroundColor Red
               Get-Service -ComputerName $ServerName -Name $ServiceName | Stop-Service -Force 
            
         }}
         Get-Service -ComputerName $ServerName -Name $ServiceName | Select-Object -Property Status,Name
      }

      function Invoke-VmSnapshots{
         <#
               .SYNOPSIS
               Describe purpose of "Invoke-VmSnapshots" in 1-2 sentences.

               .DESCRIPTION
               Add a more complete description of what the function does.

               .EXAMPLE
               Invoke-VmSnapshots
               Describe what this call does

               .NOTES
               Place additional notes here.

               .LINK
               URLs to related sites
               The first link is opened by Get-Help -Online Invoke-VmSnapshots

               .INPUTS
               List of input types that are accepted by this function.

               .OUTPUTS
               List of output types produced by this function.
         #>
         [CmdletBinding()]
         param(
         )
         $HighlightTextColor = 'Yellow'
         $ListBorder = '============================='
         $Snapshotinfo = get-vm | get-snapshot  | Sort-Object -Property Created,SizeGB -Descending | Select-Object -Property VM,Name,Created,@{n='SizeGb'
         e={'{0:N2}' -f $_.SizeGb}}#, id -AutoSize
         If ($Snapshotinfo.count -ne 0){
            Write-Host `n "Snapshot information of all VM's in our vsphere." -foreground $HighlightTextColor -BackgroundColor Black
            Write-Host $ListBorder -foregroundcolor $HighlightTextColor
            $Snapshotinfo  | Select-Object -Property *
            Write-Host $ListBorder -foregroundcolor $HighlightTextColor
         }
  
      }

      function Copy-ImportantVMs(){
         <#
               .SYNOPSIS
               Describe purpose of "Copy-ImportantVMs" in 1-2 sentences.

               .DESCRIPTION
               Add a more complete description of what the function does.

               .EXAMPLE
               Copy-ImportantVMs
               Describe what this call does

               .NOTES
               Place additional notes here.

               .LINK
               URLs to related sites
               The first link is opened by Get-Help -Online Copy-ImportantVMs

               .INPUTS
               List of input types that are accepted by this function.

               .OUTPUTS
               List of output types produced by this function.
         #>


         [CmdletBinding()]
         param(
         )
      
      }

      function Move-VmToOneHost(){
         <#
               .SYNOPSIS
               Describe purpose of "Move-VmToOneHost" in 1-2 sentences.

               .DESCRIPTION
               Add a more complete description of what the function does.

               .EXAMPLE
               Move-VmToOneHost
               Describe what this call does

               .NOTES
               Place additional notes here.

               .LINK
               URLs to related sites
               The first link is opened by Get-Help -Online Move-VmToOneHost

               .INPUTS
               List of input types that are accepted by this function.

               .OUTPUTS
               List of output types produced by this function.
         #>


         [CmdletBinding()]
         param(
         )
      
      }

      function Set-HostsMaintenanceMode(){
         <#
               .SYNOPSIS
               Describe purpose of "Set-HostsMaintenanceMode" in 1-2 sentences.

               .DESCRIPTION
               Add a more complete description of what the function does.

               .EXAMPLE
               Set-HostsMaintenanceMode
               Describe what this call does

               .NOTES
               Place additional notes here.

               .LINK
               URLs to related sites
               The first link is opened by Get-Help -Online Set-HostsMaintenanceMode

               .INPUTS
               List of input types that are accepted by this function.

               .OUTPUTS
               List of output types produced by this function.
         #>


         [CmdletBinding()]
         param(
      
         )
      
      }

   } # End - Process Block
   End {
   
   } # End - End Block

}