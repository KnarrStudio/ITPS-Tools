
<#

    Version Road Map: 
    1. Automate the Shutdown procedures
    a. Stop Services that need to be stopped
    b. Turn off DRS
    c. Move VM's to specific Host and Snapshot
    d. Power off VM's
    e. Put Hosts in maintenance mode
    f. Shut down Hosts
    2. Automate the Power On produre after turning the Hosts back on.
    a. Remove Hosts from Maintenance mode
    b. Start Powering on VM's in a specific order
    c. Start services that may have been set to "disabled" or "manual"
    d. Turn DRS back on
    e. Restart all workstations
    3. Logging and Reports
    a. Log the operations to provide a report of and timeline
    4. Allow Admin to select different options
    a. Full power outage with logging
    b. Emergency Power off all servers
    c. Put all hosts in Maintenance mode.
    d. Do a "Dry Run" with logging
    e. Power on or off specific servers based on Tags or Host
    f. shutdown with or without Snapshots
    g. Remove all Snapshots and create new for shutdown
    h. Clone some systems
   
    Purpose: Completely automate the Power off procedures in the event that we need to shut down for a power outage.

#>

function Start-PowerOutage
{
  <#
      .Synopsis
      Completely automate the Power off procedures in the event that we need to shut down for a power outage.

      .DESCRIPTION
      Automate the Power off procedures in the event that we need to shut down for a power outage.
   
      .EXAMPLE
      Example of how to use this cmdlet
      .EXAMPLE
      Another example of how to use this cmdlet

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Start-PowerOutage

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  [OutputType([int])]
  Param
  (
    # 
    [Parameter(Mandatory,HelpMessage = 'Type of power outage, Planned, Unplanned, Emergency',
        ValueFromPipelineByPropertyName,
    Position = 0)]
    [Object]$Type,

    # Snapshots WithMemory or Without memory.  Snapshots with memory take longer, but if think there might be problems after the restart you will want to use this.  
    # Snapshots Key. Where only some systems with have the memory snapped.  This would be good in an Unplanned or emergency situation
        
    [Parameter(Mandatory)][String]
    $Snapshots,
        
    [Switch]
    $SnapshotsKey
  )

  Begin
  {
  } # Beging - END
  Process
  {
    function script:Move-CriticalVmToPrimaryHost
    {
      param
      (
        [Parameter(Mandatory)][Object]$HostOne,

        [Parameter(Mandatory)][Object]$HostTwo
      )

      function Get-VmsFromHost
      {
        param
        (
          [Object]
          [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Data to filter')]
          $InputObject
        )
        process
        {
          if ($InputObject.vmhost.name -eq $HostOne)
          {
            $InputObject
          }
        }
      }

      do
      {
        $servers = get-vm | Get-VmsFromHost
        foreach($server in $servers)
        {
          #Moving $server from $HostOne to $HostTwo
          move-vm $server -Destination $HostTwo
        }
      }while((get-vm | Get-VmsFromHost).count -ne 0)

      Write-Verbose -Message 'Moves Completed!'
    }
  } # Process - END
  End
  { 
  } # End - END
}



Shutdown-VmServers -Name 'Server1', 'Server2' -Order 'Tag' -Type 'Planned', 'Unplanned', 'Emergency', 'DryRun'

function Shutdown-VmServers
{
  <#
      .SYNOPSIS
      Short description of what Shutdown-VmServers does
      .DESCRIPTION
      Detailed description of what Shutdown-VmServers does
      .EXAMPLE
      First example
      Shutdown-VmServers
      .EXAMPLE
      Second example
      Shutdown-VmServers
  #>

  [CmdletBinding()]
  param
  (
    # Parameter description
    [Parameter(Position = 0, Mandatory = $true)]
    [string[]]
    $VmName,

    # Parameter description
    [Parameter(Position = 1, Mandatory = $false)]
    [string]
    $Order,

    # Parameter description
    [Parameter(Mandatory = $true)]
    [ValidateSet('Planned', 'Unplanned', 'Emergency','DryRun')]
    [string]
    $Type
  )


  # TODO: place your function code here
  # this code gets executed when the function is called
  # and all parameters have been processed
}



function MoveVMsRebootHost($HostOne,$HostTwo)
{
  do
  {
    $servers = get-vm | Where-Object -FilterScript {
      $_.vmhost.name -eq $HostOne
    }
    foreach($server in $servers)
    {
      #Write-Host "Moving $server from $HostOne to $HostTwo"
      move-vm $server -Destination $HostTwo
    }
  }while((get-vm | Where-Object -FilterScript {
        $_.vmhost.name -eq $HostOne
  }).count -ne 0)

  if((get-vm | Where-Object -FilterScript {
        $_.vmhost.name -eq $HostOne
  }).count -eq 0)
  {
    $null = Set-VMHost $HostOne -State Maintenance
    $null = Restart-vmhost $HostOne -confirm:$false 
  }
  do 
  {
    Start-Sleep -Seconds 15
    $ServerState = (get-vmhost $HostOne).ConnectionState
    Write-Host "Shutting Down $HostOne" -ForegroundColor Magenta
  }
  while ($ServerState -ne 'NotResponding')
  Write-Host "$HostOne is Down" -ForegroundColor Magenta

  do 
  {
    Start-Sleep -Seconds 60
    $ServerState = (get-vmhost $HostOne).ConnectionState
    Write-Host "Waiting for Reboot ..."
  }
  while($ServerState -ne 'Maintenance')
  Write-Host "$HostOne back online"
  $null = Set-VMHost $HostOne -State Connected 
}
