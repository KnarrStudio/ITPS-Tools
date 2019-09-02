function Invoke-SystemShutdown
{
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
    [Parameter(Mandatory,HelpMessage = 'Full= All VMs and Hosts, Partial = Only ones tagged. Test = None')]
    [ValidateSet('Full', 'Partial', 'Test')]
    [string]$ShutdownType
  ) # End - Invoke-SystemShutdown param
   
  Begin{
    $ServerList = "$env:HOMEDRIVE\Temp\ServerList.csv"  ## List of servers in order of shutdown (Name,Order,SpecialTask)
    $LogFileOutput = "$env:HOMEDRIVE\Temp\LogFileOutput.log" ## File to write to as this script runs
    $ShutDownArgreement = "$env:HOMEDRIVE\temp\ShutDownArgreement" ## File holds information and steps for the shutdown process
  
  $SignAgreement = 'N'
    Get-Content -Path $ShutDownArgreement
    $SignAgreement = Read-Host -Prompt 'Do you agree and have the above information Y/[N] '
    if($SignAgreement -eq 'y')
    {
      $DateTimeStamp = Get-Date -UFormat %M%S #-%m/%d/%Y
      $AdminsFullName = Read-Host -Prompt 'Enter your full name '
      $DirecteBy = Read-Host -Prompt 'Name of person directing the shutdown'
      $SignedShutdownAgreement = ('{0}-{1}.txt' -f $ShutDownArgreement, $DateTimeStamp)
      Copy-Item -Path $ShutDownArgreement -Destination $SignedShutdownAgreement
      Write-Output -InputObject ('Today {0}. I, {1}, signed into {2} as {3} agree to the above Shutdown Agreement.  This task has been directed by {4}. _______________________  ' -f $DateTimeStamp, $AdminsFullName,$env:COMPUTERNAME, $env:username,$DirecteBy) | Out-File -FilePath $SignedShutdownAgreement -Append
      #$SignedShutdownAgreement | Out-Printer 'EPSONA280B3 (XP-440 Series)'

    }
    Else
    {
      break
    }

    if($ShutdownType -eq 'Test')
    {
      If ($WhatIfPreference -ne $true)
      {
        $script:WhatIfPreference = $true
        Write-Warning -Message ('Testing Mode is {0}' -f $WhatIfPreference)
      } # End - Switch-Safety
    }
  } # End - Begin Block
   
  Process {
    function Set-ServerService
    {
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
        [string]$ServerName = 'filesvr',
        [string]$ShutdownType = 'Test'#,
        #$LogFileOutput = "$env:HOMEDRIVE\temp\ErrorLogFile.txt"
      )
         
      $ServiceStatus = Get-Service -ComputerName $ServerName -Name $ServiceName

      if ($ServiceStatus.Status -eq 'Stopped')
      {
        Write-Output -InputObject 'DFS Replication Service is Off.... ' | Out-File -FilePath $LogFileOutput -Append
        if($ShutdownType -ne 'Test')
        {
          Write-Verbose -Message 'Starting Service...' 
          Write-Output  -InputObject 'Starting Service...' | Out-File -FilePath $LogFileOutput -Append
          Set-Service -ComputerName $ServerName -Name $ServiceName -Status Running -StartupType Automatic
        }
      }
 
      if ($ServiceStatus.Status -eq 'Running')
      {
        Write-Verbose -Message 'DFS Replication Service is On....'
        #$b = Read-Host -Prompt 'Do you want to stop it? [N]'
        if($ShutdownType -ne 'Test')
        {
          Write-Verbose -Message 'Stopping Service...'
          Write-Output  -InputObject 'Stopping Service...' | Out-File -FilePath $LogFileOutput -Append
          Get-Service -ComputerName $ServerName -Name $ServiceName | Stop-Service -Force 
        }
      }
      Get-Service -ComputerName $ServerName -Name $ServiceName | Select-Object -Property Status, Name
    }

    function Invoke-VmSnapshots
    {
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
         
      $ListBorder = '============================='
         
      $Snapshotinfo = get-vm |
      get-snapshot |
      Select-Object -Property VM, Name, Created, @{n = 'SizeGb';e = {'{0:N2}' -f $_.SizeGb}}#, id -AutoSize
      If ($Snapshotinfo.count -ne 0)
      {
        Write-Verbose -Message "Snapshot information of all VM's in our vsphere."
        Write-Verbose -Message $ListBorder
        $Snapshotinfo  | Sort-Object -Property Created, SizeGB -Descending
        Write-Verbose -Message $ListBorder
      }
      # ADD - Create Snapshots
    }

    function Copy-ImportantVMs()
    {
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
      # Po'Boy backup for the shutdown.  These servers are identified in the cvs file and tagged.
    }

    function Move-VmToOneHost()
    {
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

    function Set-HostsMaintenanceMode()
    {
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

    function Stop-Hosts
    {
      <#
          .SYNOPSIS
          Describe purpose of "Stop-Hosts" in 1-2 sentences.

          .DESCRIPTION
          Add a more complete description of what the function does.

          .EXAMPLE
          Stop-Hosts
          Describe what this call does

          .NOTES
          Place additional notes here.

          .LINK
          URLs to related sites
          The first link is opened by Get-Help -Online Stop-Hosts

          .INPUTS
          List of input types that are accepted by this function.

          .OUTPUTS
          List of output types produced by this function.
      #>


      # ADD - Shutdown Hosts that have been identified.
    }
      
  } # End - Process Block
  End {
   
    # Final logging and clean-up of open files.
   
   
  } # End - End Block
}
