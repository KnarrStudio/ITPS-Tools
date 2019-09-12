#requires -Version 1.0
function New-Folders
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    New-Folders
    explains how to use the command
    can be multiple lines
    .EXAMPLE
    New-Folders
    another example
    can have as many examples as you like
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [Object]
    $path = (Resolve-Path -Path 'folders.csv')
  )
  
  Set-Location -Path env: -PassThru 
  $Folders = Import-Csv -Path .\folders.csv
  
  ForEach ($Folder in $Folders) 
  { 
    if (!(Test-Path -Path $Folder))
    {
      Write-Output -InputObject $Folder.Name
      Write-Output -InputObject $path
      New-Item -Path $Folder.Name -ItemType directory 
    }
  }
}


 