#Requires -Module vmware.vimautomation.core

Function Show-Snapshots {
  <#
      .SYNOPSIS
      Removes Snapshots with the same Snapshot Name

      .EXAMPLE
      Remove-VMSnapshots

      .NOTES
      Script Name: RemoveSnapshots.ps1
      Author Name: Erik Arnesen
      Version : 1.3
      Contact : 5276
      <#
      Script Name: Show-Snapshots.ps1
      Author Name: Erik Arnesen
      Version : 1.3
      Contact : 5276
      Requirements
      -VMware PowerCLI

      List all the machines with snapshot running with listing VM Name, Snapshot Name, Date Created, Size MB

      Version Control
      1.0 Copied ListSnapshots.ps1 
      1.1 Change Added Grid View to make it more user friendly.
      1.2 Added test for VIserver connection
      1.3 Changed from direct output to veriable
      Added the count
  #############################################>

  #>

  # Get all of the Snapshot
  function Get-SelectedVmSnapshot
  {
    param
    (
      [Object]
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Data to filter")]
      $InputObject
    )
    process
    {
      if ($InputObject.Name -match $SnapName)
      {
        $InputObject
      }
    }
  }


<#
  if ($global:DefaultVIServers.Count -eq 0) {
    $VIserver = Read-Host "Enter IP of VI Server (214.18.207.86 or RSRCNGMVC02)"
    Connect-VIServer $VIserver
    #Connect-VIServer -menu
    $r=101
  }#>

  #Print list of Snapshots
  #get-vm | get-snapshot  | Format-Table -Property VM,Name,Created,SizeMB,id -AutoSize
  $TheSnaps = get-vm | get-snapshot  | Select-object -Property VM,Name,Created,SizeMB,id
  Write-Host "Total Snapshots "$TheSnaps.Count
  $TheSnaps  | Out-GridView -Title 'Snapshots'

<#  if ($r -eq 101) {
    Disconnect-VIServer $VIserver
  }#>
  
}