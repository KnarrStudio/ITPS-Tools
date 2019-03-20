#Requires -Module vmware.vimautomation.core

# NOTE ** Remove the "-whatif" statement for this script to work

Function Remove-VMSnapshots {
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

  $AllSnapshots = get-vm | get-snapshot  

  #Print list of all Snapshots on all VM's (ver1.3 edit done here)
  $AllSnapshots | Format-Table -Property Name,VM,Created,@{n="SizeGb";e={"{0:N2}" -f $_.SizeGb}}, id -AutoSize

  #Snapshot name checking list - ver1.2
  $SnapName = Read-Host -Prompt 'Enter the Name of the Snapshot you want to remove'

  Write-Host ('Based on the Snapshot name you entered: {0}' -f $SnapName)

  Write-Host "The following VM's have snapshots that will be removed: " 
  $AllSnapshots |  Get-SelectedVmSnapshot | Format-Table -Property VM,id -AutoSize 

  #Verification - ver1.1
  $Okay = 'N'
  $Okay = Read-host -Prompt 'If this is Okay? [N] '

  #Actual working part of code - ver1.0
  If ($Okay -eq 'Y'){
    $AllSnapshots | Get-SelectedVmSnapshot| Remove-Snapshot -confirm:$false -runasync #-whatif
  }
}