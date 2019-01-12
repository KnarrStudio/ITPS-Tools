<#
    .SYNOPSIS
    Daily checks of Active Directory, the user, the workstation and the servers.
    .DESCRIPTION
    Checks:
    Domain Controller status - Replication, Verifies the location of the FSMO roles ....  
    DFSR status - Verifies the replication delta is within exeptable limits
    Drive Space
    User Accounts - Locked out, not use for X days, disabled.
    Workstations - That have not been logged into, or are not online.
    Servers - Services that are set to auto, but not actually running
		
    Repairs or corrects:
    Domain Replication - DFSR
    Drive space - Deletes known files
    User Accounts - Unlocks, Disables user who have not logged in 30 days, Removes users who have been disabled for 15 days
    Workstations - Disables the account of machines that have not been used in X days
    Servers - Restarts Services
	
    Reports:
    Checks Status
    Repairs Completed
    .PARAMETER <paramName>
    <Description of script parameter>
    .EXAMPLE
    <An example of using the script>
#>


<# Section - AD Health #>
# Load PowerShell module for Active Directory
Import-Module -Name ActiveDirectory

# Custom function to scan specified AD domain and collect data
function Get-DomainInfo {
  param(
    [Parameter(Position=0,HelpMessage='Enter the domain name ex: unc.edu', Mandatory)]
    [string]$DomainName
  )
  begin {
    # Start of data collection for specified domain by function
    $DomainInfo = Get-ADDomain $DomainName

    # Variables definition
    $domainSID = $DomainInfo.DomainSID
    $domainDN = $DomainInfo.DistinguishedName
    $domain = $DomainInfo.DNSRoot
    $NetBIOS = $DomainInfo.NetBIOSName
    $dfl = $DomainInfo.DomainMode

    # Domain FSMO roles
    $FSMOPDC = $DomainInfo.PDCEmulator
    $FSMORID = $DomainInfo.RIDMaster
    $FSMOInfrastructure = $DomainInfo.InfrastructureMaster

    $DClist = $DomainInfo.ReplicaDirectoryServers
    $RODCList = $DomainInfo.ReadOnlyReplicaDirectoryServers

    $cmp_location = $DomainInfo.ComputersContainer
    $usr_location = $DomainInfo.UsersContainer

    $FGPPNo = 'feature not supported'
    
    $DomainControllers =  Get-ADDomainController -Server $domain
    
  }
  process {
    # Get Domain Controller with at least Windows Server 2008 R2
    $DCListFiltered = Get-ADDomainController -Server $domain -Filter { operatingSystem -like 'Windows Server 2008 R2*' -or operatingSystem -like 'Windows Server 2012*' -or operatingSystem -like 'Windows Server Technical Preview'  } | Select-Object -Property * -ExpandProperty Name
    $DCListFiltered | ForEach-Object{ $DCListFilteredIndex = $DCListFilteredIndex+1 }
  }
}

end {
  Export-ModuleMember -Function Get-Foo
}





<# Section - Drive Space #>


<# Section - Users #>


<# Section - Workstation #>


<# Section - Servers #>



