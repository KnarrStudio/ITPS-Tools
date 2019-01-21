Function Show-DynamicMenu
{
  <#
      .SYNOPSIS
      Creates a menu based on items in a file or directory

      .DESCRIPTION
      Checks for the menu.csv file and displays the contents as a menu. If the file does not exist, it looks in the local directory and returns a menu based on the folders or files.  
      By default it shows files, but you can pass a "Folders" and get a list of folders

      .EXAMPLE
      Show-DynamicMenu
      Shows a menu based on the menu.csv file if it exists, otherwise, it shows a menu base on the files in the current directory

      .EXAMPLE
      Show-DynamicMenu -Folders
      Shows Menu base on the folders in the current directory
 
      .EXAMPLE
      Show-DynamicMenu -inputFile .\test2.csv
      If you want to change the input filename from menu.csv
      Shows Menu base on the files in the file.
      The file must have "Name" as the title of the column. ("Name" must be on the first line)
      
      File Format:       Output Format:
      Name               0. Exit
      Move               1. Move
      Delete             2. Delete
      Select number: 


      .NOTES
      Handly way to provide a selection if you want to have a menu that needs to be dynamic.  
      When you need to modify something in the directory which changes regularly.
      Or you don't want to rebuild a menu.

      .INPUTS
      looks for "menu.csv" file first

      .OUTPUTS
      Passes or prints the selection of the menu as a name
  #>
  [CmdletBinding()]
  param
  (
    [switch]$Folders,
    [Switch]$Files,
    [String]$inputFile = "$env:HOMEDRIVE\temp\menu.csv"
  )
    
  if (Test-Path -Path $inputFile){
    $DirectoryItems = Import-Csv -Path $inputFile
    Write-Debug -Message ("Txt File True - `n{0}" -f $DirectoryItems)
  }
  Else{  
    if($Folders)
    {
      $DirectoryItems = Get-ChildItem -Directory 
      Write-Debug -Message ("Folders Switch True - `n{0}" -f $DirectoryItems)
    }
    Else{
      $DirectoryItems = Get-ChildItem -file
      Write-Debug -Message ("Files switch True - `n{0}" -f $DirectoryItems)
    }
  }
  $menu = @{}
  $folderCount = $DirectoryItems.Count-1
  for($i = 0;$i -lt $DirectoryItems.count;$i++)
  {
    if($i -eq 0)
    {
      Write-Host ('{0}. {1}' -f $i, 'Exit')
      $i++
    }
    Write-Host ('{0}. {1}' -f $i, $DirectoryItems[$i].name)
    $menu.Add($i,($DirectoryItems[$i].name))
  }
  $ans = 99
  do{[int]$ans = Read-Host -Prompt 'Select number'
    if($ans -ne 0)
    {
      if(($ans -ge $folderCount) -or ($ans -lt 0))
      {
        Write-Warning -Message ('Select a number from 0 to {0}' -f $folderCount)
      }
    }
  } 
  while($ans -notin 0..$folderCount)
 
  $selection = $menu.Item($ans)
   <###################
     Run Amazing code by passing $selection to the next function
     
     Return $selection
  ###################>
   
  # Visual output for Testing
  Write-Host 'You selected: '$selection -ForegroundColor Magenta
    

}
Show-DynamicMenu