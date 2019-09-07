#Requires -Version 3.0 
#  R e q uires -Modules ActiveDirectory, DnsClient
#Requires -RunAsAdministrator

<#
    .SYNOPSIS
    Copy backup files from source to destination and capture metadata for historical information and future planning
    .DESCRIPTION
    <A detailed description of the script>
    .PARAMETER <paramName>
    <Description of script parameter>
    .EXAMPLE
    <An example of using the script>
#>

function New-TimedStampFileName {
  <#
      .SYNOPSIS
      Creates a file where a time stamp in the name is needed
      .DESCRIPTION
      Allows you to create a file with a time stamp.  You provide the base name, extension, date format and it should do the rest.
      .PARAMETER baseNAME
      Describe parameter -baseNAME.
      .PARAMETER tailNAME
      Describe parameter -tailNAME.
      .PARAMETER StampFormat
      Describe parameter -StampFormat.
      .EXAMPLE
      New-TimedStampFileName -baseNAME TestFile -tailNAME ext -StampFormat 2
      This creates a file TestFile-20170316.ext 
      .NOTES
      This should be written in a way that will allow you to incert it into your script and use as a function
      .INPUTS
      Any authorized file name for the base and an extension that has some value to you.
      .OUTPUTS
      Filename-20181005.bat
  #>
  param
  (
    [Parameter(Mandatory,HelpMessage='Prefix of file or log name')]
    [alias('Prefix')]
    $baseNAME,
    [Parameter(Mandatory,HelpMessage='Extention of file.  txt, csv, log')]
    [alias('Extension')]
    $tailNAME,
    [Parameter(Mandatory,HelpMessage='Formatting Choice 1 to 4')]
    [alias('Choice')]
    [ValidateRange(1,4)]
    $StampFormat
  )
  switch ($StampFormat){
    1{$t = Get-Date -uformat '%y%m%d%H%M'} # 1703162145 YYMMDDHHmm
    2{$t = Get-Date -uformat '%Y%m%d'} # 20170316 YYYYMMDD
    3{$t = Get-Date -uformat '%d%H%M%S'} # 16214855 DDHHmmss
    4{$t = Get-Date -uformat '%y/%m/%d_%H:%M'} # 17/03/16_21:52
    default{'No time format selected'}
  }
  $baseNAME+'-'+$t+'.'+$tailNAME
}

function Get-DriveInformation
{
  #Content
  get-wmiobject -Class Win32_Share | Sort-Object -Property Name | Select-Object -Property Name, Path, Status

  get-wmiobject -Class Win32_MappedLogicalDisk | Select-Object -Property Name, Description, FileSystem, @{Label='Size';Expression={"{0,12:n0} MB" -f ($_.Size/1mb)}}, @{Label="Free Space";Expression={"{0,12:n0} MB" -f ($_.FreeSpace/1mb)}}, ProviderName
   

}

function Get-FileMetadata
{
  #Content
  

}

function Move-Files
{
  #Content
  

}

function Set-InputFileData
{
  #Content
  

}


Export-NpsConfiguration -Path "<Path>\$($env:COMPUTERNAME)-NPS-$(Get-Date -Uformat %Y%m%d).xml"
Copy-Item -Path "<Same Path\$($env:COMPUTERNAME)-NPS-$(Get-Date -Uformat %Y%m%d).xml" -Destination '<UNC Path>'
exit


