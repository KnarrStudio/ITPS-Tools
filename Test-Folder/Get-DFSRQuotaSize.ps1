#requires -Version 3.0
function Get-DFSRQuotaSize
{
  <#
      .SYNOPSIS
      Returns the recomended size of the DFS-R Quota

      .EXAMPLE
      Get-DFSRQuotaSize -Path 'S:\DFSR-Folder'
      Will give you the quota to the screen.

      .EXAMPLE 
      Get-DFSRQuotaSize -Path 'S:\DFSR-Folder' -LogFolder c:\temp\Logs
      Will give you the quota to a file in the folder you provide

      .EXAMPLE
      Get-DFSRQuotaSize -Path 'S:\DFSR-Folder' -LogFolder c:\temp\Logs -verbose
      Will give you the quota to a file in the folder you provide.  It will also output the path.
  #>
  
  [CmdletBinding(SupportsPaging)]
  Param
  (
    [Parameter(Mandatory, Position = 0,HelpMessage = 'Enter the full path of the DFS-R path. S:\DFSR-Folder')]
    [string]$FullPath,
    
    [Parameter(Position = 1)]
    [string]$LogFolder = $null
  )

  $DateNow = Get-Date -UFormat %Y%m%d-%S
  $LogFile = (('{0}\{1}-DfsrQuota.txt' -f $LogFolder, $DateNow))

  $Big32 = Get-ChildItem -Path $FullPath -Recurse |
  Sort-Object -Property length -Descending |
  Select-Object -First 32 |
  Measure-Object -Property length -Sum
  $DfsrQuota = $Big32.sum /1GB

  $OutputInformation = ('The path tested: {0}.  The recommended Quota size is {1:n2} GB' -f $FullPath, $DfsrQuota)
  Write-Output -InputObject $OutputInformation

  if($LogFolder)
  {
    ('Raw Full Path = {0}' -f $FullPath) | Out-File -FilePath $LogFile
    ('Raw Quota = {0}' -f $DfsrQuota) | Out-File -FilePath $LogFile -Append
    ('Username = {0}' -f $env:USERNAME) | Out-File -FilePath $LogFile -Append
    Write-Output -InputObject ('The log can be found: {0}' -f  $LogFile)
  }

  Write-Verbose -Message ('Log file = {0} ' -f $LogFile)
  Write-Verbose -Message ('Raw Full Path = {0}' -f $FullPath)
  Write-Verbose -Message ('Raw Quota = {0}' -f $DfsrQuota)
}



