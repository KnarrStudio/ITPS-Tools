function New-TimedStampFileName {
  <#
    .SYNOPSIS
    Creates a file where a time stamp in the name is needed

    .DESCRIPTION
    Allows you to create a file with a time stamp.  You provide the base name, extension, date format and it should do the rest.

    .PARAMETER baseNAME
    This is the primary name of the file.  It will be followed by the date/time stamp.

    .PARAMETER FileType
    The extension. ig. csv, txt, log

    .PARAMETER StampFormat
    Describe parameter -StampFormat.

    .EXAMPLE
    New-TimedStampFileName -baseNAME TestFile -FileType log -StampFormat 2
    This creates a file TestFile-20170316.log

    .NOTES
    This should be written in a way that will allow you to insert it into your script and use as a function


    .INPUTS
    Any authorized file name for the base and an extension that has some value to you.

    .OUTPUTS
    example output - Filename-20181005.bat
  #>



  param
  (
    [Parameter(Mandatory,HelpMessage='Prefix of file or log name')]
    $baseNAME,
    [Parameter(Mandatory,HelpMessage='Extention of file.  txt, csv, log')]
    [alias('Extension')]
    $FileType,
    [Parameter(Mandatory,HelpMessage='Formatting Choice 1 to 4')]
    [ValidateRange(1,4)]
    $StampFormat
  )

  switch ($StampFormat){
    1{$DateStamp = Get-Date -uformat '%y%m%d%H%M'} # 1703162145 YYMMDDHHmm
    2{$DateStamp= Get-Date -uformat '%Y%m%d'} # 20170316 YYYYMMDD
    3{$DateStamp= Get-Date -uformat '%d%H%M%S'} # 16214855 DDHHmmss
    4{$DateStamp= Get-Date -uformat '%y/%m/%d_%H:%M'} # 17/03/16_21:52
    default{'No time format selected'}
  }

  $baseNAME+'-'+$DateStamp+'.'+$FileType
}