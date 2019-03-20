#Requires -Module vmware.vimautomation.core

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

      New-Snapshot -vm $Server -Name $SnapName -Description $SnapDesc -runasync
    }
  }
	
  end{
  
    Write-Verbose -Message ('Start End Section')
  }
}
