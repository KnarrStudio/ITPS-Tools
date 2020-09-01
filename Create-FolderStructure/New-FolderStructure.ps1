#requires -Version 3.0
function New-Folders
{
  <#
      .SYNOPSIS
      Uses a CVS file to create a folder structure.

      .DESCRIPTION
      Uses a CVS file to create a folder structure.  
      The CVS only needs one column named "FolderPath".  
      From there you can go as much depth as you need.  "test1\test2" "Test1\test2\test3\test4"
      Place the file into the root of where you want the folder structure to begin.
    
      .PARAMETER FolderList
      This is the CSV file that has the following structure.
    
      FolderPath
      Test1\Test1
      Test1\Test2
      Test1\test3\test1
      Test1\test3\test2

  #>
  param
  (
    [Parameter(ValueFromPipeline,HelpMessage='CSV file to pull paths from',Mandatory=$true, Position = 0)]
    [ValidateScript({
          If($_ -match '.csv')
          {
            $true
          }
          Else
          {
            Throw 'Input file needs to be CSV'
          }
    })][String]$FolderList 
  )
  
  Write-Verbose -Message ('FolderList: {0}' -f $FolderList)
  
  $RootPath = (Resolve-Path -Path $FolderList | Split-Path -Parent)
  Write-Verbose -Message ('RootPath: {0}' -f $RootPath)
  
  $Folders = Import-Csv -Path $FolderList
  Write-Verbose -Message ('Folders: {0}' -f $Folders )
  
  ForEach ($Folder in $Folders) 
  { 
    $FullPath = ('{0}\{1}' -f $RootPath, $Folder.FolderPath)
    Write-Verbose -Message $FullPath
    if (-not (Test-Path -Path $FullPath))
    {
      try
      {
        New-Item -Path $FullPath -ItemType directory -ErrorAction Stop
      }
      catch
      {
        Write-Warning -Message 'Folder path exists'
      }
    }
  }
}



$FolderList  = '.\folders.csv' 
$FolderList | New-Folders -Verbose
 
