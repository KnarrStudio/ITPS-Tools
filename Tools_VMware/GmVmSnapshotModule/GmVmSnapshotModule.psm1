#Requires -Module vmware.vimautomation.core
#Requires -version 3.0


Function New-VmSnapshot{
  <#
      .SYNOPSIS
      Creates Snapshots of the selected VM or all powered on VM's and gives the Snapshot a common Name

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER VMServers
      One or many server names separated by ","

      .PARAMETER SnapshotName
      Standard name of the snapshot ('Updates', 'Troubleshooting', 'SoftwareInstallation','Other').  This will be added to the date stamp.

      .PARAMETER SnapshotDescription
      By default 'Created by Script New-VmSnapshot.ps1' Run by "Username".  You can change this as required.

      .PARAMETER All
      Switch to run against all of the powered on servers.  You can also add the servername 'All' to snapshot all of the powered on servers.  Adding this to the command will disregard any and all servers listed.

      .EXAMPLE
      New-VmSnapshot -VMServers Value -SnapshotName Value -SnapshotDescription Value
      This will create snapshots of each VmServers listed
    
      .NOTES
      Copy of this located in onenote search for the script name: "NewVmSnapshots.psm1"
      Author Name: Erik Arnesen
      Contact : 5276

  #>
  
  [Cmdletbinding()]
  
  Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('computername','hostname')]
    [ValidateLength(3,14)]
    [string[]]$VMServers,
    
    [Parameter(Mandatory=$true,HelpMessage='Reason for Snapshot')]
    [ValidateSet('Updates', 'Troubleshooting', 'SoftwareInstallation','Other')] 
    [string]$SnapshotName,
    [string]$SnapshotDescription = 'Created by Script New-VmSnapshot.ps1',
    [Switch]$All
  )
  
  begin{
  
    Write-Verbose -Message ('Start Begin Section')

    #Get List of all Powered On VM's
    function Get-AllPoweredOnVms
    {
      param
      (
        [Object]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Data to filter')]
        $InputObject
      )
      process
      {
        if (($InputObject.powerstate -eq 'PoweredOn') -and ($InputObject.name -notlike '*FS*') -and ($InputObject.name -notlike '*DC*'))
        {
          $InputObject
        }
      }
    }

    #Write-Verbose ('VMservers {0}' -f $VMServers)
    
    if($VMServers -eq 'All') {
      Write-Verbose -Message ('All Selected')

      $VMServers = @()
      $VMServers =  get-vm | Get-AllPoweredOnVms 
      Write-Information -MessageData 'Creating Snapshots of all systems' -InformationAction Continue
    }
	  
    #Create Time/Date Stamp
    $TDStamp = Get-Date -UFormat '%Y%m%d'
	
    #Get User Information
    [String]$SysAdmIntl = $env:username
    #Name of Snapshot
    [String]$SnapName = ('{0}-{1}' -f $TDStamp, $SnapshotName)
    # Description of Snapshot
    [String]$SnapDesc = ('{0} -- Run by: {1}' -f $SnapshotDescription, $SysAdmIntl)

    #Write-Verbose -Message ('Using Server List: {0}' -f $VMServers)
    Write-Verbose -Message ('Naming Snapshots: {0}' -f $SnapName)
  }
  
  process{
  
    Write-Verbose -Message ('Start Process Section')

    foreach ($Server in $VMServers) {
      Write-Verbose -Message ('New Snapshot of {0}' -f $Server)

      if($SnapshotName -eq ('SoftwareInstallation' -or 'Troubleshooting')){
        New-Snapshot -vm $Server -Name $SnapName -Description $SnapDesc -Quiesce:$true
      
      }
      else
      {
        New-Snapshot -vm $Server -Name $SnapName -Description $SnapDesc -runasync
      }
    }
  }
	
  end{
  
    Write-Verbose -Message ('Start End Section')
  }
}

# NOTE ** Remove the "-whatif" statement for this function to work

Function Remove-VMSnapshots {
  <#
      .SYNOPSIS
      An easy way to bulk remove Snapshots that have the same Snapshot Name

      .EXAMPLE
      Remove-VMSnapshots 

      .NOTES
      Script Name: RemoveSnapshots.ps1
      Author Name: Erik Arnesen
      Version : 1.3
      Contact : 5276
      
  #>

  # Get the selected Snapshots
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



Function Show-VmSnapshots {
  <#
      .SYNOPSIS
      Shows the current snapshots.  List all the machines with snapshot running with listing VM Name, Snapshot Name, Date Created, Size MB
 

      .EXAMPLE
      Show-VMSnapshots

      .NOTES

      Author Name: Erik Arnesen
      Version : 1.3
      Contact : 5276
      Requirements
      -VMware PowerCLI

      
  #############################################>

  #>

  

  if ($global:DefaultVIServers.Count -eq 0) {
    Connect-VIServer -menu
  }

  # Get all of the Snapshot
  $TheSnaps = get-vm | get-snapshot  | Select-object -Property VM,Name,Created,SizeMB,id
  
  
  # Display a list of Snapshots
  Write-Host "Total Snapshots "$TheSnaps.Count
  $TheSnaps  | Out-GridView -Title 'Snapshots'

  <#  if ($r -eq 101) {
      Disconnect-VIServer $VIserver
  }#>
  
}


#Export-ModuleMember -Function Show-VmSnapshots, New-VmSnapshot, Remove-VMSnapshots
