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
  
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true, Position = 0,HelpMessage = 'Enter the full path of the DFS-R path. S:\DFSR-Folder')]
    [string]$FullPath = '.\',
    
    [Parameter(Mandatory = $false, Position = 1,HelpMessage = 'Enter the Log path. \\NetworkShare\Logs\')]
    [string]$LogFolder = $null
)

$DateNow = Get-Date -UFormat %Y%m%d-%S
$LogFile = (('{0}\{1}-DfsrQuota.txt' -f $LogFolder, $DateNow))

$Big32 = Get-ChildItem $FullPath -recurse | Sort-Object length -descending | select-object -first 32 | measure-object -property length –sum
$DfsrQuota = $Big32.sum /1GB

$OutputInformation = ('The path tested: {0}.  The recommended Quota size is {1:n2} GB' -f $FullPath,$DfsrQuota)
Write-Output $OutputInformation

if($LogFolder)
{
    ('Raw Full Path = {0}' -f $FullPath) | Out-File $LogFile
    ('Raw Quota = {0}' -f $DfsrQuota) | Out-File $LogFile -Append
    ('Username = {0}' -f $env:USERNAME) | Out-File $LogFile -Append
    Write-Output ('The log can be found: {0}' -f  $Logfile)
}

Write-Verbose ('Log file = {0} ' -f $LogFile)
Write-Verbose ('Raw Full Path = {0}' -f $FullPath)
Write-Verbose ('Raw Quota = {0}' -f $DfsrQuota)

}



