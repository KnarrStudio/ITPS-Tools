Function Show-DynamicMenu
{
  <#
      .SYNOPSIS
      Creates a menu of folders or files

      .DESCRIPTION
      Looks at the folder shows a list of numbered options based on the items in the folder.  
      
      .EXAMPLE
      Show-DynamicMenu -Files
      Shows Menu based on the Files in the current locations

      0    Exit
      1    autovar.csv
      2    Commands.csv
      3    Commands.xlsx 

      Selecting the #2 will return $selection = to 'Commands.csv'

      Add the Folders or All switches to create menus with those items

      .PARAMETER Files
      Builds the Menu based on the Files

      .PARAMETER Folders
      Builds the Menu based on the Folders.

      .PARAMETER All
      Builds the Menu based on All items.

      .NOTES
      Handly way to provide a selection if you want to have a menu that needs to be dynamic

      .OUTPUTS
      Returns the $Selection as a name
  #>

  param
  (
    [Parameter(HelpMessage='Select what you want a menu of.  Files, Folders, or all')]
    [switch]$Files,
    [Switch]$Folders,
    [Switch]$All
  )

  $i = 0
  $ans = $null
  $menu = [ordered]@{}
    
  if($Files)  
  {
    $DirectoryItems = Get-ChildItem -File 
  }
  if($Folders)  
  {
    $DirectoryItems = Get-ChildItem -Directory 
  }
  if($All)  
  {
    $DirectoryItems = Get-ChildItem 
  }
  
  foreach($DirectoryItem in $DirectoryItems)
  {
    if($i -eq 0)
    {
      $menu.Add($i, 'Exit') 
    }
    $i++
    $menu.Add($i,($DirectoryItem.name)) 
    
  }
  $menu | Format-Table -HideTableHeaders -AutoSize
  
  $ItemCount = $DirectoryItems.name.Count
   
  while($ans -notin 0..$ItemCount)
  {
    [int]$ans = Read-Host -Prompt 'Select number'
    if($ans -ge $ItemCount )
    {
      Write-Host ('Select {0} or below' -f $ItemCount) 
    }
    $selection = $menu.Item($ans)
    
    Write-Host 'You selected:'$selection -ForegroundColor Magenta
  }
  Return $selection
}

