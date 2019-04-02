#Requires -Modules VMware.VimAutomation.Core
#Requires -RunAsAdministrator

Function Get-VMInformation 
{
  <#
      .SYNOPSIS
      Gives a quick status of the VM Environment
      .EXAMPLE
      Get-CurrentVMInformation
      Displays the Powered On Servers, Powered Off Servers, Servers that are running from the clone 'COOP' and lists the snapshots
      .OUTPUTS
      Output to Console. 

  #>
  function Get-VmWithPowerState
  {
    param
    (
      [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Data to filter')]
      [Object]$InputObject,
      [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Data to filter')]
      [ValidateSet('PoweredOn','PoweredOff')]
      [String]$PowerState
    )
    process
    {
      if($InputObject.PowerState -eq $PowerState)
      {
        $InputObject
      }

    }
  }
  $ALLvms = get-vm
  $Snapshots = get-vm | get-snapshot
  $null = Get-VMHost 
  $PoweredOffVM = $ALLvms | Get-VmWithPowerState -PowerState 'PoweredOff'
  $PoweredOnVM = $ALLvms | Get-VmWithPowerState -PowerState 'PoweredOn'
  $COOPSinuse = $ALLvms | Where-Object {($_.Name -match 'COOP')} | Get-VmWithPowerState -PowerState 'PoweredOn'
  $Snapshotsinfo = $Snapshots | Sort-Object -Property Created,SizeGB -Descending
    
  Write-Host `n 
  Write-Host ('List of Powered Off VMs: {0}' -f $PoweredOffVM) -ForegroundColor Red
  Write-Host ('List of Powered ON Servers: {0}' -f $PoweredOnVM) -ForegroundColor Green
  Write-Host ('List of COOPd Servers in use: {0}' -f $COOPSinuse) -ForegroundColor Blue
  Write-Host ('Snapshot Information: {0}' -f $Snapshotsinfo) -ForegroundColor Red
}

Get-VMInformation 
