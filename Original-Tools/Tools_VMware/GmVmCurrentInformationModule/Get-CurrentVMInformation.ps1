#Requires -Modules VMware.VimAutomation.Core
#Requires -RunAsAdministrator

Function Get-VMInformation 
{
  <#
      .SYNOPSIS
      Gives a quick status of the VM Environment
      
      .EXAMPLE
      Get-CurrentVMInformation -Output File
      Sends the Powered On Servers, Powered Off Servers, Servers that are running from the clone 'COOP' and snapshots to a file.
      
      .EXAMPLE
      Get-CurrentVMInformation -CloneBase COOP
      Displays the Powered On and Off Servers, Servers that are running from a cloned machine that you named a with the "CloneBase" common name.  The default is "COOP', but it is whatever you use.
      
      .EXAMPLE
      Get-CurrentVMInformation
      Displays the Powered On Servers, Powered Off Servers, Servers that are running from the clone 'COOP' and lists the snapshots
      
      .OUTPUTS
      Output to Console. 

  #>
  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'Low')]
  Param
  (
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Send Out to')]
    #[ValidateSet('Screen','File')]
    [Switch]$File,
    [Parameter(Mandatory = $False, ValueFromPipeline, HelpMessage = 'Base name of Clone.  The default is "COOP"')]
    [String]$CloneBase = 'COOP'
  )
  
  function Get-VmWithPowerState
  {
    param
    (
      [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Data to filter')]
      [Object]$InputObject,
      [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Data to filter')]
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
  $Snapshots = $ALLvms | get-snapshot
  $null = Get-VMHost 
  $PoweredOffVM = $ALLvms | Get-VmWithPowerState -PowerState 'PoweredOff'
  $PoweredOnVM = $ALLvms | Get-VmWithPowerState -PowerState 'PoweredOn'
  $ClonesInuse = $PoweredOnVM | Where-Object -FilterScript {
    ($_.Name -match $CloneBase)
  }
  $Snapshotsinfo = $Snapshots | Sort-Object -Property Created, SizeGB -Descending
  



  if(-not $File)
  {
    Write-Host `n 
    Write-Host ('List of Powered Off VMs:') -ForegroundColor Red
    Write-Host ($PoweredOffVM)
    Write-Host ('List of Powered ON Servers: {0}' -f $PoweredOnVM) -ForegroundColor Green
    Write-Host ('List of Cloned Servers in use: {0}' -f $ClonesInuse) -ForegroundColor Blue
    Write-Host ('Snapshot Information: {0}' -f $Snapshotsinfo) -ForegroundColor Red
  }

  Get-Date | Out-File -FilePath c:\Temp\outputfile.txt -Append
  $ALLvms |
  Sort-Object -Property Powerstate |
  Out-File -FilePath c:\Temp\outputfile.txt -Append
  $Snapshotsinfo | Out-File -FilePath C:\Temp\outputfile.txt -Append
}

#Get-VMInformation 
